require 'sinatra'

class Server < Sinatra::Application
  ALLOWED_ACCESS_IP = %w[99.80.183.117 99.81.135.32]

  # Ensure all requests come from a fixed IP
  before do
    return unless ENV['RACK_ENV'] == 'production'
    requesting_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.env['REMOTE_ADDR']

    unless ALLOWED_ACCESS_IP.include?(requesting_ip)
      notify_telegram(:info, "Unexpected API Access by IP '#{requesting_ip}'")
      halt 401, { msg: "I'm afraid I can't let you do that, #{requesting_ip}" }.to_json
    end
  end

  # Notify on all errors
  error Exception do
    Services::TelegramOperator.notify(:error, env['sinatra.error'].inspect)
    { msg: 'Something went wrong' }.to_json
  end

  get '/' do
    { msg: 'Please contact an admin to use the api' }.to_json
  end

  get '/global' do
    daily   = Serializers::Global::DailyStats.serialize
    parcels = Serializers::Global::Parcels.serialize
    scenes  = {}
    users   = Serializers::Global::Users.serialize

    {
      global: daily,
      parcels: parcels,
      scenes: scenes,
      users: users
    }.to_json
  end

  get '/peer_status' do
    date = Date.today - 1
    Models::ApiResponseStatus.where(date: date).all

    # format:
    # "date": '2022-09-18',
    # "url": "https://peer-ec1.decentraland.org/lambdas/profiles",
    # "statuses": {
    #   "200": 16,·
    #   "429": 1
    # },
    # "failure_rate": x,
    # "success_count": 16,
    # "failure_count": 1

  end

  private

  def notify_telegram(lvl, msg)
    Services::TelegramOperator.notify(level: lvl, message: msg)
  end
end
