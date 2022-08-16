require 'sinatra'

class Server < Sinatra::Application
  ALLOWED_ENDPOINTS = %w[/ /about]
  ALLOWED_ACCESS_IP = %w[99.80.183.117 99.81.135.32]

  before do
    requesting_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.env['REMOTE_ADDR']

    unless ALLOWED_ACCESS_IP.include?(requesting_ip)
      halt 401, { msg: "I'm afraid I can't let you do that, #{requesting_ip}" }.to_json
    end
  end

  get '/' do
    { msg: 'Please contact an admin to use the api' }.to_json
  end

  post '/internal_metrics' do
    p '##################################################'
    p request
    p '##################################################'

    request.body.rewind
    data = JSON.parse(request.body.read)
    endpoint = data.delete('endpoint')

    unless ALLOWED_ENDPOINTS.include?(endpoint)
      Services::TelegramOperator.notify(
        level: :info,
        message: "Unexpected endpoint '#{endpoint}' accessed",
        payload: data
      )
    end

    date = Date.today.to_s
    timestamp = Time.now.utc.to_i
    # NOTE: later need to parse like Time.at(timestamp).utc

    # creates potential for RIM Job naming
    Models::RawInternalMetrics.update_or_create(date: date, endpoint: endpoint) do |m|
      existing_metrics = m.metrics_json.nil? ? [] : JSON.parse(m.metrics_json)

      duplicated_metric = existing_metrics.any? && existing_metrics.detect do |em|
        # data is the same and not within a 3s time delta
        em.except('timestamp') == data && (timestamp - 3) < em['timestamp']
      end

      unless duplicated_metric
        m.metrics_json = existing_metrics.
          push(data.merge(timestamp: timestamp)).
          to_json
      end
    end

    status 201
    {}.to_json
  end

  get '/global' do
    daily   = Models::DailyStats.recent.map(&:serialize)
    parcels =  Serializers::Global::Parcels.serialize
    scenes  = {}
    users   = Serializers::Global::Users.serialize

    {
      global: daily,
      parcels: parcels,
      scenes: scenes,
      users: users
    }.to_json
  end
end
