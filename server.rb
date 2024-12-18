require 'sinatra'

class Server < Sinatra::Application
  # access management
  before do
    # don't limit endpoints unless they are on production
    return unless ENV['RACK_ENV'] == 'production'

    requesting_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.env['REMOTE_ADDR']
    return if valid_api_key?(requesting_ip)

    # block anyone without access
    failure(403, "I'm afraid I can't let you do that, #{requesting_ip}")
  end

  # Notify on all errors
  error Exception do
    notify_telegram(:error, env['sinatra.error'].inspect)

    { msg: 'Something went wrong' }.to_json
  end

  get '/' do
    { msg: 'Please contact an admin to use the api' }.to_json
  end

  get '/global/daily' do
    response = Adapters::Backblaze::ReadFile.call(bucket: 'global-stats', filename: 'unique-daily')

    if response.success?
      response.body
    else
      { error: 'something went wrong, please contact admin' }.to_json
    end
  end

  get '/global/parcels' do
    Serializers::Global::Parcels.serialize.to_json
  end

  get '/global/scenes' do
    Serializers::Global::Scenes.serialize.to_json
  end

  get '/global/users' do
    Serializers::Global::Users.serialize.to_json
  end

  get '/utilization' do
    data = FAT_BOY_DATABASE["
        select active_deploy, count(*) / sum(count(*)) over () as percentage
        from parcels
        group by active_deploy"
      ].all

    result = data.detect { |x| x[:active_deploy] == true }[:percentage].round(4).to_f * 100

    { global_utilization: result }.to_json
  end

  get '/rentals/summary' do
    { message: 'sorry, this endpoint no longer exists' }.to_json
  end

  get '/rentals/closed' do
    { message: 'sorry, this endpoint no longer exists' }.to_json
  end

  get '/worlds/global' do
    response = Adapters::Backblaze::ReadFile.call(bucket: 'global-stats', filename: 'worlds')

    if response.success?
      response.body
    else
      { error: 'something went wrong, please contact admin' }.to_json
    end
  end

  get '/worlds/current' do
    dump = Models::WorldsDump.order(:created_at).last
    data = dump.data
    worlds = dump.data['data'].map do |world|
      name = world['name']

      {
        name: name,
        ens_token: name.sub('.dcl.eth', ''),
        url: "https://play.decentraland.org/?realm=#{name}",
        user_count: world['user_count'],
        scenes: world['scenes'].map { |scene| scene.except('pointers') }
      }
    end

    {
      timestamp: dump.created_at.to_i,
      currently_occupied: data['total_rooms'],
      current_users: data['total_user_count'],
      dcl_worlds_count: data['world_count']['dcl'],
      ens_worlds_count: data['world_count']['ens'],
      total_count: data['world_count'].values.sum,
      data: worlds
    }.to_json
  end

  get '/worlds/user/:address' do
    # TODO but maybe this is way easier by name?
  end

  get '/events/:id' do
    event = Models::Event.new(params[:id])

    if event.errors.any?
      status 400
      return { msg: event.errors.first }.to_json
    end

    return { scene_uuid: event.scene_disambiguation_uuid } if params['only_uuid']
    event.serialize.to_json
  end

  get '/scenes/top' do
    scenes = Models::DailySceneStats.
      basic_data.
      where(date: params[:date] || Date.today - 1).
      order(:unique_addresses).
      last(50)

    Serializers::Scenes.serialize(scenes, basic_data_only: true).to_json
  end

  get '/scenes/compare' do
    range = params['range'].to_i || 7
    uuids = params['uuids'].split(',')

    Models::DailySceneStats.
      select(:name, :date, params['metric'].to_sym).
      where(scene_disambiguation_uuid: uuids).
      where { date >= Date.today - range }.
      all.group_by(&:name).map do |name, data|
        {
          name: name,
          values: data.map { |row| { date: row[:date].to_s, value: row[params['metric'].to_sym] } }
        }
      end.to_json
  end

  # TODO: select the first date when there are multiple results (so lose distinct)
  # if the first result for first_seen_at is nil, find the first daily_scene model?
  get '/scenes/search' do
    query = "select distinct scene_disambiguation_uuid as uuid from scenes"

    case
    when params['coordinates'] && params['name']
      query += " where coordinates LIKE '%#{params['coordinates']}%' and UPPER(name) LIKE UPPER('%#{params['name']}%')"
    when params['coordinates']
      query += " where coordinates LIKE '%#{params['coordinates']}%'"
    when params['name']
      query += " where UPPER(name) LIKE UPPER('%#{params['name']}%')"
    end

    ids = FAT_BOY_DATABASE[query].first(10).map(&:values).flatten

    # TODO: first_seen_at should really be renamed to "deployed_at"
    # TODO: there is likely a way to do more of this in pure SQL and it will be
    # a lot faster
    Models::Scene.
      where(scene_disambiguation_uuid: ids).
      all.
      group_by(&:scene_disambiguation_uuid).
      map do |uuid, scenes|
        first_deployed_at = scenes.min_by { |s| s.first_seen_at.to_s }.first_seen_at.to_s
        last_deployed_at = scenes.max_by { |s| s.first_seen_at.to_s }.first_seen_at.to_s

        {
          name: scenes[0].name,
          coordinates: scenes[0].coordinates,
          first_deployed_at: (first_deployed_at.empty? ? nil : first_deployed_at),
          last_deployed_at: (last_deployed_at.empty? ? nil : last_deployed_at),
          uuid: uuid,
          map_url: scenes[0].map_url,
          deploy_count: scenes.count
        }
      end.
      sort_by { |scene| scene[:last_deployed_at].to_s }.
      reverse.
      to_json
  end

  get '/scenes/:uuid' do
    basic_data_only = params[:basic_data_only] || false
    data = basic_data_only ? Models::DailySceneStats.basic_data : Models::DailySceneStats

    stats = data.where(scene_disambiguation_uuid: params[:uuid])
    failure(404, "Can't find scene with uuid #{params[:uuid]}") if stats.nil?

    # return stats for the given date or the most recent daily stats available
    stats = params[:date] ? stats.first(date: params[:date]) : stats.order(:date).last
    failure(404, "Can't find scene with uuid #{params[:uuid]}") if stats.nil?

    Serializers::Scenes.serialize([stats], basic_data_only: basic_data_only).first.to_json
  end

  get '/scenes/:uuid/history' do
    offset = params[:offset] || 0
    limit = params[:limit] || 30
    failure(400, "Max limit is 30 days") if limit > 30

    basic_data_only = params[:basic_data_only] || false
    data = basic_data_only ? Models::DailySceneStats.basic_data : Models::DailySceneStats
    stats = data.
      where(scene_disambiguation_uuid: params[:uuid]).
      order(:date)
    failure(404, "Can't find scene with uuid #{params[:uuid]}") if stats.empty?

    serialized = Serializers::Scenes.serialize(
      stats.limit(limit).offset(offset).all,
      basic_data_only: basic_data_only
    )

    {
      total: stats.count,
      data: serialized
    }.to_json
  end

  get '/scenes/:uuid/report' do
    data = Models::DailySceneStats.
      basic_data.
      where(scene_disambiguation_uuid: params[:uuid]).
      order(:date)

    failure(404, "Can't find scene with uuid #{params[:uuid]}") if data.empty?

    serialized = Serializers::Scenes.serialize_for_csv(data)
    filename = "#{data.first.name.split.join('-')}_#{Date.today.to_s}.csv"
    file = Tempfile.new(filename)
    file.write(serialized)
    file.rewind

    send_file file, filename: filename, type: 'text/csv', disposition: 'attachment'

    file.close
    file.unlink
  end

  get '/scenes/:uuid/visitor_history' do
    limit = 90
    limit = nil if params[:show_all]

    query = "select x.date, coalesce(dss.unique_visitors, 0) as visitors
            from (
              select generate_series(min(date), max(date), '1d')::date as date
              from daily_scene_stats
            ) x
            left join daily_scene_stats dss
            on dss.scene_disambiguation_uuid = '#{params[:uuid]}' and dss.date = x.date
            order by x.date desc"

    query += " limit #{limit}" unless limit.nil?

    # NOTE: formatting is "wrong" cause it's a ruby date,
    # but transforming to json fixes it so whatever
    FAT_BOY_DATABASE[query].all.reverse.to_json
  end

  get '/parcels/all' do
    # TODO:
    # for individual parcels (different endpoint)
    # coordinates = params['coordinates']
    # parcels = Models::DailyParcelStats.yesterday.where(coordinates: coordinates)
    # result = Serializers::Parcels.serialize(parcels)

    date = params[:date] || Date.today - 1
    Models::SerializedDailyParcelStats.find(date: date)&.data_json
  end

  get '/users/hyperactive' do
    timeframe_in_days = (params['timeframe_in_days'] || 30).to_i
    active_voters = Models::UserDaoActivity.
                    where { latest_vote_cast_at >= Date.today - timeframe_in_days }
    active_users  = Models::User.
                    where(address: active_voters.map(&:address)).
                    where { last_seen >= Date.today - timeframe_in_days }

    addresses = active_users.map(&:address)

    {
      total: addresses.count,
      data: addresses
    }.to_json
  end

  # NOTE: i'm making a result and then pushing each serialized model *in order*
  # into that result rather than just mapping the results. This was a pain to
  # understand, but calling User.where(id: ids).map doesn't preserve the order
  # of the query since where introduces a default sort order
  get '/users/search' do
    result = []
    query = "select id
            from users
            where UPPER(name) LIKE UPPER('%#{params['name']}%')
            order by (name = '#{params['name']}') desc, length(name)"
    ids = FAT_BOY_DATABASE[query].first(10).map(&:values).flatten

    ids.each do |id|
      result.push(Serializers::User.serialize(Models::User[id]))
    end

    result.to_json
  end

  get '/users/:address' do
    user = Models::User.find(address: params[:address].downcase)
    failure(404, "Can't find user with address #{params[:address]}") if user.nil?

    Serializers::User.serialize(user).to_json
  end

  get '/users/:address/activity/top_scenes' do
    user = Models::User.find(address: params[:address].downcase)
    failure(404, "Can't find user with address #{params[:address]}") if user.nil?

    user.top_scenes_visited.to_json
  end

  get '/users/:address/activity/scenes_visited' do
    user = Models::User.find(address: params[:address].downcase)
    failure(404, "Can't find user with address #{params[:address]}") if user.nil?

    user.scenes_visited_histogram.to_json
  end

  get '/users/:address/activity/time_spent' do
    user = Models::User.find(address: params[:address].downcase)
    failure(404, "Can't find user with address #{params[:address]}") if user.nil?

    user.time_spent_histogram.to_json
  end

  get '/users/:address/nfts' do
    user = Models::User.find(address: params[:address].downcase)
    failure(404, "Can't find user with address #{params[:address]}") if user.nil?

    nfts = user.nfts
    base_attributes = {
      address: params[:address],
      name: user.name,
      avatar_url: user.avatar_url,
    }

    if nfts
      base_attributes.merge(
        {
          owns_nfts: true,
          owns_dclens: nfts.owns_dclens,
          owns_land: nfts.owns_land,
          owns_wearables: nfts.owns_wearables,
          total_dclens: nfts.total_dclens,
          total_lands: nfts.total_lands,
          total_wearables: nfts.total_wearables,
          first_dclens_acquired_at: nfts.first_dclens_acquired_at.to_s,
          first_land_acquired_at: nfts.first_land_acquired_at.to_s,
          first_wearable_acquired_at: nfts.first_wearable_acquired_at.to_s,
          participant_in_genesis_auction: nfts.participated_in_genesis_auction?,
          og_user: nfts.og?
        }
      ).to_json
    else
      base_attributes.merge({ owns_nfts: false }).to_json
    end
  end

  get '/users/:address/dao_activity' do
    user = Models::User.find(address: params[:address].downcase)
    failure(404, "Can't find user with address #{params[:address]}") if user.nil?

    dao_activity = user.dao_activity
    base_attributes = {
      address: params[:address],
      name: user.name,
      avatar_url: user.avatar_url
    }

    # TODO: this pattern of parsing json just to immediately
    # turn it back to json is fucking insane. surely there's a better way
    if dao_activity
      # it can be the user has a dao_activity model but no actual activity.
      # this happens (as far as i have seen) in cases where the user is a
      # collection creator but has never voted / taken other actions
      delegators = (user.dao_activity&.delegators || "").split(';').map do |d|
        d_user = Models::User.find(address: d.downcase)

        {
          address: d,
          dao_user: d_user&.dao_member? || false,
          name: d_user&.name,
          avatar_url: d_user&.avatar_url,
          vp: d_user&.dao_activity&.total_vp
        }
      end

      base_attributes.merge(
        {
          dao_member: true,
          title: dao_activity.title,
          total_vp: dao_activity.total_vp || 0,
          delegated_vp: dao_activity.delegated_vp || 0,
          delegators: delegators,
          delegate: dao_activity.delegate,
          votes: {
            total_votes: dao_activity.votes_count || 0,
            first_vote_cast_at: dao_activity.first_vote_cast_at.to_s,
            latest_vote_cast_at: dao_activity.latest_vote_cast_at.to_s,
          },
          grants: dao_activity.grants,
          proposals: {
            count: dao_activity.proposals_count || 0,
            data: JSON.parse(dao_activity.proposals_json || '[]')
          },
          active_dao_committee_member: dao_activity.active_dao_committee_member,
          teams: JSON.parse(dao_activity.teams_json || '[]'),
          collection_creator: dao_activity.collection_creator,
          collections: JSON.parse(dao_activity.collections_json || '[]')
        }
      ).to_json
    else
      base_attributes.merge({ dao_member: false }).to_json
    end
  end

  get '/peer_status' do
    # NOTE: maybe we want to provide more dates later
    # but for now just use yesterday's data
    date = Date.today - 1
    api_responses = Models::ApiResponseStatus.where(date: date).all

    Serializers::PeerStatus.serialize(api_responses).to_json
  end

  private

  def failure(status_code, msg)
    halt [status_code, { msg: msg}.to_json]
  end

  def notify_telegram(lvl, msg)
    Services::TelegramOperator.notify(level: lvl, message: msg)
  end

  def valid_api_key?(ip_address)
    key = request.env["HTTP_API_KEY"]
    return false unless key

    api_key = Models::ApiKey.find(key: key)
    return false unless api_key

    endpoint = request.env["REQUEST_PATH"]

    log_params = {
      endpoint: endpoint,
      ip_address: ip_address,
      key: key,
      query_params_json: params.to_json
    }

    if api_key.expired?
      expired_msg = "Your API key '#{key}' has expired"
      Models::ApiKeyAccessLog.create(log_params.merge(response: 498))
      halt 498, { msg: expired_msg }.to_json
    end

    unless api_key.permitted?(endpoint)
      unauthorized_msg = "Your API key '#{key}' is not authorized to access #{endpoint}"
      Models::ApiKeyAccessLog.create(log_params.merge(response: 401))
      halt 401, { msg: unauthorized_msg }.to_json
    end

    # TODO: requests per time period
    # rate_limited_msg = "Your API key '#{key}' has made too many requests and is timed out"
    # return halt 403, { msg: rate_limited_msg }.to_json if api_key.rate_limited?

    # log api_key usage
    Models::ApiKeyAccessLog.create(log_params.merge(response: 200))

    true
  end
end
