require 'sinatra'

class Server < Sinatra::Application
  ALLOWED_ACCESS_IP = %w[99.80.183.117 99.81.135.32 95.90.232.62]

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
    scene_data = Models::SerializedDailySceneStats.where(date: Date.today - 1)

    {
      global: Serializers::Global::DailyStats.serialize,
      parcels: Serializers::Global::Parcels.serialize,
      scenes: {
        yesterday: scene_data.detect { |s| s.timeframe == 'yesterday' }.data,
        last_week: scene_data.detect { |s| s.timeframe == 'last_week' }.data,
        last_month: scene_data.detect { |s| s.timeframe == 'last_month' }.data,
        last_quarter: scene_data.detect { |s| s.timeframe == 'last_quarter' }.data
      },
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

  get '/dashboard/:dashboard_name' do
    scenes = dashboard_mapping[params[:dashboard_name].to_sym].order(:date)
    serialized = Serializers::Scenes.serialize(scenes.all)

    {
      daily_users: result.map { |scene| [scene[:date], scene[:visitors]] }.to_h,
      result: result.map { |scene| [scene[:date], scene] }.to_h
    }.to_json
  end

  private

  def notify_telegram(lvl, msg)
    Services::TelegramOperator.notify(level: lvl, message: msg)
  end

  def dashboard_mapping
    {
      goldfish: fetch_scene_stats(goldfish_coordinates, 'DCL Scene'),
      ups_store: fetch_scene_stats(ups_store_coordinates, 'The UPS Store')
    }
  end

  def fetch_scene_stats(coordinates, name)
    Models::DailySceneStats.where(coordinates: coordinates, name: name)
  end

  def goldfish_coordinates
    [
      "102,-141","103,-141","104,-141","105,-141","106,-141","107,-141",
      "102,-142","103,-142","104,-142","105,-142","106,-142","107,-142",
      "102,-143","103,-143","104,-143","105,-143","106,-143","107,-143",
      "102,-144","103,-144","104,-144","105,-144","106,-144","107,-144",
      "102,-145","103,-145","104,-145","105,-145","106,-145","107,-145",
      "102,-146","103,-146","104,-146","105,-146","106,-146","107,-146"
    ].sort.join(';')
  end

  def ups_store_coordinates
    ["-25,-8","-24,-8","-25,-9","-24,-9"].sort.join(';')
  end
end
