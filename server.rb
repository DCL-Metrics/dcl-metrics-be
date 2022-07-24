require 'sinatra'

class Server < Sinatra::Application
  get '/' do
    "fetched #{Models::PeersDump.count} times"
  end

  get '/api/stats' do
    Models::DailyStats.recent.map(&:serialize).to_json
  end

  get '/api/user_stats' do
    Models::DailyUserStats.recent.map(&:serialize).to_json
  end

  get '/api/parcel_stats' do
    Models::DailyParcelStats.recent.map(&:serialize).to_json
  end
end
