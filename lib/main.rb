print "##############################\n\n"
print "Using DATABASE:  #{ENV['DATABASE_URL']}\n\n"
print "##############################\n"

require 'sequel'
DATABASE_CONNECTION = Sequel.connect(ENV['DATABASE_URL'])
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :update_or_create

require 'sidekiq'
Sidekiq.configure_client do |config|
  config.redis = {
    db: 0,
    url: ENV['REDIS_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

Sidekiq.configure_server do |config|
  config.redis = {
    db: 0,
    url: ENV['REDIS_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

# require models
require './lib/models/peers_dump.rb'
require './lib/models/data_point.rb'
require './lib/models/user_event.rb'
require './lib/models/user_activity.rb'

# require jobs
require './lib/jobs/job.rb'
require './lib/jobs/fetch_peer_data.rb'
require './lib/jobs/process_snapshot.rb'
require './lib/jobs/process_daily_user_activity.rb'

# require services
require './lib/services/daily_traffic_calculator.rb'
require './lib/services/daily_user_activity_builder.rb'
