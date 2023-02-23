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
      halt 403, { msg: "I'm afraid I can't let you do that, #{requesting_ip}" }.to_json
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

  # TODO: use Models::SerializedDailySceneStats
  # maybe need to add some additional rows for sorting / queries
  # (concurrent users, addresses, etc)
  get '/scenes/top' do
    scenes = Models::DailySceneStats.yesterday.order(:unique_addresses).last(10)

    Serializers::Scenes.serialize(scenes).to_json
  end

  get '/scenes/:uuid' do
    stats = Models::DailySceneStats.find(
      date: params[:date] || Date.today - 1,
      scene_disambiguation_uuid: params[:uuid]
    )
    return [404, { msg: "Can't find scene with uuid #{params[:uuid]}" }.to_json] if stats.nil?

    Serializers::Scenes.serialize([stats]).first.to_json
  end

  get '/scenes/:uuid/history' do
    DATABASE_CONNECTION[
      "select date, unique_visitors
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

    if scenes.empty?
      Services::RequestLogger.call(**reporting_params.merge(status: 404))
      halt 404, { msg: "I can't find data about '#{params[:scene_name]}'" }.to_json
    end

    data = scenes.
      last(30).
      map { |x| [x.date.to_s, x.unique_addresses, x.avg_time_spent] }.
      prepend(%w[date visitors avg_time_spent_in_seconds avg_time_spent_afk_in_seconds])

    filename = "#{params[:scene_name]}.csv"
    file = Tempfile.new(filename)
    file.write(data)
    file.rewind

    Services::RequestLogger.call(**reporting_params.merge(status: 200))
    send_file file, filename: filename, type: 'text/csv', disposition: 'attachment'

    file.close
    file.unlink
  end

  private

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

    expired_msg = "Your API key '#{key}' has expired"
    Models::ApiKeyAccessLog.create(log_params.merge(response: 498))
    return halt 498, { msg: expired_msg }.to_json if api_key.expired?

    unauthorized_msg = "Your API key '#{key}' is not authorized to access #{endpoint}"
    Models::ApiKeyAccessLog.create(log_params.merge(response: 401))
    return halt 401, { msg: unauthorized_msg }.to_json unless api_key.permitted?(endpoint)

    # TODO: requests per time period
    # rate_limited_msg = "Your API key '#{key}' has made too many requests and is timed out"
    # return halt 403, { msg: rate_limited_msg }.to_json if api_key.rate_limited?

    # log api_key usage
    Models::ApiKeyAccessLog.create(log_params.merge(response: 200))

    true
  end
end
