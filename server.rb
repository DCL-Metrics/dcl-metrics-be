require 'sinatra'

class Server < Sinatra::Application
  ALLOWED_ACCESS_IP = %w[99.80.183.117 99.81.135.32]

  before do
    requesting_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.env['REMOTE_ADDR']

    unless ALLOWED_ACCESS_IP.include?(requesting_ip)
      Services::TelegramOperator.notify(
        level: :info,
        message: "Unexpected API Access by IP '#{requesting_ip}'"
      )

      halt 401, { msg: "I'm afraid I can't let you do that, #{requesting_ip}" }.to_json
    end
  end

  get '/' do
    { msg: 'Please contact an admin to use the api' }.to_json
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
