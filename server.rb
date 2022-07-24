require 'sinatra'

class Server < Sinatra::Application
  get '/' do
    "fetched #{Models::PeersDump.count} times"
  end

  get '/api/stats' do
    Models::DailyStats.recent.map(&:serialize).to_json
  end

  get '/api/user_stats/:attribute' do
    unless %w[time_spent parcels_visited].include?(params[:attribute])
      status 400
      return { msg: "#{params[:attribute]} is not valid." }.to_json
    end

    Models::DailyUserStats.
      recent.
      order(params[:attribute].to_sym).
      all.
      group_by { |stats| stats.date.to_s }.
      transform_values! { |v| v.map(&:serialize) }.
      to_json
  end

  get '/api/parcel_stats' do
    Models::DailyParcelStats.
      recent.
      all.
      group_by { |stats| stats.date.to_s }.
      transform_values! { |v| v.map(&:serialize) }.
      to_json
  end
end
