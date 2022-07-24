require 'sinatra'

class Server < Sinatra::Application
  get '/' do
    "fetched #{Models::PeersDump.count} times"
  end

  get '/api/stats' do
    Models::DailyStats.recent.map(&:serialize).to_json
  end

  get '/api/user_stats/:attribute' do
    attribute = params[:attribute].to_sym

    unless %i[time_spent parcels_visited].include?(attribute)
      status 400
      return { msg: "#{attribute.to_s} is not valid." }.to_json
    end

    Models::DailyUserStats.
      recent.
      exclude(attribute => nil).
      reverse_order(attribute).
      all.
      group_by { |stats| stats.date.to_s }.
      sort_by(&:first).
      to_h.
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
