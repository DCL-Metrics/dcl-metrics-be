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
    notify_telegram(:error, env['sinatra.error'].inspect)

    { msg: 'Something went wrong' }.to_json
  end

  get '/' do
    { msg: 'Please contact an admin to use the api' }.to_json
  end

  get '/global' do
    {
      global: Serializers::Global::DailyStats.serialize,
      parcels: Serializers::Global::Parcels.serialize,
      scenes: Serializers::Global::Scenes.serialize,
      users: Serializers::Global::Users.serialize
    }.to_json
  end

  get '/scenes/top' do
    scenes = Models::DailySceneStats.yesterday.order(:unique_addresses).last(10)

    Serializers::Scenes.serialize(scenes).to_json
  end

  get '/peer_status' do
    # NOTE: maybe we want to provide more dates later
    # but for now just use yesterday's data
    date = Date.today - 1
    api_responses = Models::ApiResponseStatus.where(date: date).all

    Serializers::PeerStatus.serialize(api_responses).to_json
  end

  private

  def notify_telegram(lvl, msg)
    Services::TelegramOperator.notify(level: lvl, message: msg)
  end
end
