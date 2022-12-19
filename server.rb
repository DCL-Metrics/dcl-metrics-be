require 'sinatra'

class Server < Sinatra::Application
  ALLOWED_ACCESS_IP = %w[99.80.183.117 99.81.135.32 95.90.235.137]

  # Ensure all requests come from a fixed IP
  before do
    # don't limit endpoints unless they are on production
    return unless ENV['RACK_ENV'] == 'production'

    # don't limit the reports namespace
    return if request.env["REQUEST_PATH"].split('/')[1] == 'reports'

    # handle IP based blocking
    requesting_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.env['REMOTE_ADDR']

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

  get '/dashboard/:dashboard_name' do
    scenes = dashboard_mapping[params[:dashboard_name].to_sym].order(:date)
    serialized = Serializers::Scenes.serialize(scenes.all)

    {
      available_dates: serialized.map { |scene| scene[:date] }.sort,
      daily_users: serialized.map { |scene| [scene[:date], scene[:visitors]] }.to_h,
      result: serialized.map { |scene| [scene[:date], scene] }.to_h
    }.to_json
  end

  get '/reports/:scene_name' do
    scenes = Models::DailySceneStats.
      where(name: params[:scene_name]).
      order(:date).
      select(:date, :unique_addresses, :avg_time_spent)

    reporting_params = { url: "api.dcl-metrics.com/reports", params: params }

    if scenes.empty?
      Services::RequestLogger.call(**reporting_params.merge(status: 404))
      halt 404, { msg: "I can't find data about '#{params[:scene_name]}'" }.to_json
    end

    data = scenes.
      last(30).
      map { |x| [x.date.to_s, x.unique_addresses, x.avg_time_spent] }.
      prepend(%w[date visitors avg_time_spent_in_seconds])

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

  def dashboard_mapping
    {
      edifice: fetch_scene_stats(edifice_coordinates, 'Edifice Metaversal'),
      goldfish: fetch_scene_stats(goldfish_coordinates, 'DCL Scene'),
      ups_store: fetch_scene_stats(ups_store_coordinates, 'The UPS Store')
    }
  end

  def fetch_scene_stats(coordinates, name)
    Models::DailySceneStats.where(coordinates: coordinates, name: name)
  end

  def edifice_coordinates
    [
      "10,-37", "10,-38", "10,-39", "11,-33", "11,-34", "11,-35", "11,-36",
      "11,-37", "11,-38", "11,-39", "12,-33", "12,-34", "12,-35", "12,-36",
      "12,-37", "12,-38", "12,-39", "2,-39", "3,-39", "4,-39", "4,-40",
      "4,-41", "4,-42", "5,-39", "5,-42", "6,-39", "6,-42", "6,-43", "6,-44",
      "6,-45", "6,-46", "7,-37", "7,-38", "7,-39", "7,-40", "7,-41", "7,-42",
      "8,-37", "8,-38", "8,-39", "9,-37", "9,-38", "9,-39"
    ].sort.join(';')
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
