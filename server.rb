require 'sinatra'

class Server < Sinatra::Application
  ALLOWED_ACCESS_IP = %w[99.80.183.117 99.81.135.32 95.90.237.179]

  # Extremely sophisticated access management
  before do
    # don't limit endpoints unless they are on production
    return unless ENV['RACK_ENV'] == 'production'

    requesting_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.env['REMOTE_ADDR']
    api_key = fetch_valid_api_key(request.env, requesting_ip)
    return if api_key

    # don't limit the reports namespace
    return if request.env["REQUEST_PATH"].split('/')[1] == 'reports'

    # handle IP based blocking
    unless ALLOWED_ACCESS_IP.include?(requesting_ip)
      failure(403, "I'm afraid I can't let you do that, #{requesting_ip}")
    end
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
    Serializers::Global::DailyStats.serialize.to_json
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

  get '/scenes/top' do
    scenes = Models::DailySceneStats.
      basic_data.
      where(date: params[:date] || Date.today - 1).
      order(:unique_addresses).
      last(50)

    Serializers::Scenes.serialize(scenes, basic_data_only: true).to_json
  end

  get '/scenes/search' do
    data = Models::Scene.
      distinct(:name).
      select(
        :coordinates,
        :first_seen_at,
        :name,
        Sequel.as(:scene_disambiguation_uuid, :uuid)
      )

    data = data.where { Sequel.like(:name, "%#{params[:name]}%") } if params[:name]
    data = data.where { Sequel.like(:coordinates, "%#{params[:coordinates]}%") } if params[:coordinates]

    data.first(10).map(&:values).to_json
  end

  get '/scenes/:uuid' do
    basic_data_only = params[:basic_data_only] || false
    data = basic_data_only ? Models::DailySceneStats.basic_data : Models::DailySceneStats

    stats = data.first(
      date: params[:date] || Date.today - 1,
      scene_disambiguation_uuid: params[:uuid]
    )
    failure(404, "Can't find scene with uuid #{params[:uuid]}") if stats.nil?

    Serializers::Scenes.serialize([stats], basic_data_only: basic_data_only).first.to_json
  end

  get '/scenes/:uuid/history' do
    offset = params[:offset] || 0
    limit = params[:limit] || 30
    failure(400, "Max limit is 30 scenes") if limit > 30

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

  get '/scenes/:uuid/visitor_history' do
    DATABASE_CONNECTION[
      "select date, unique_visitors as visitors
      from daily_scene_stats
      where scene_disambiguation_uuid = '#{params[:uuid]}'
      order by date desc
      limit 91"
    ].all.reverse.to_json
  end

  get '/parcels/all' do
    # TODO:
    # for individual parcels (different endpoint)
    # coordinates = params['coordinates']
    # parcels = Models::DailyParcelStats.yesterday.where(coordinates: coordinates)
    # result = Serializers::Parcels.serialize(parcels)

    date = Date.today - 1
    Models::SerializedDailyParcelStats.find(date: date)&.data_json
  end

  get '/peer_status' do
    # NOTE: maybe we want to provide more dates later
    # but for now just use yesterday's data
    date = Date.today - 1

    # TODO: we'll exclude all "internal" calls later directly in the model
    api_responses = Models::ApiResponseStatus.
      where(date: date).
      exclude(url: 'api.dcl-metrics.com/reports').
      all

    Serializers::PeerStatus.serialize(api_responses).to_json
  end

  get '/reports/:uuid' do
    scenes = Models::DailySceneStats.
      where(scene_disambiguation_uuid: params[:uuid]).
      order(:date).
      select(:date, :unique_addresses, :avg_time_spent, :avg_time_spent_afk)

    reporting_params = { url: "api.dcl-metrics.com/reports", params: params }
    scene_name = params[:scene_name] || scenes.last&.name || 'unknown scene'

    if scenes.empty?
      Services::RequestLogger.call(**reporting_params.merge(status: 404))
      failure(404, "Can't find data about '#{scene_name}'")
    end

    data = scenes.
      last(30).
      map { |x| [x.date.to_s, x.unique_addresses, x.avg_time_spent] }.
      prepend(%w[date visitors avg_time_spent_in_seconds avg_time_spent_afk_in_seconds])

    filename = "#{scene_name}.csv"
    file = Tempfile.new(filename)
    file.write(data)
    file.rewind

    Services::RequestLogger.call(**reporting_params.merge(status: 200))
    send_file file, filename: filename, type: 'text/csv', disposition: 'attachment'

    file.close
    file.unlink
  end

  private

  def failure(status_code, msg)
    halt [status_code, { msg: msg}.to_json]
  end

  def notify_telegram(lvl, msg)
    Services::TelegramOperator.notify(level: lvl, message: msg)
  end

  def fetch_valid_api_key(env, ip_address)
    key = env["HTTP_API_KEY"]
    return unless key

    api_key = Models::ApiKey.find(key: key)
    return unless api_key

    endpoint = env["REQUEST_PATH"]
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
