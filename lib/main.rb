print "##############################\n\n"
print "Using DATABASE:  #{ENV['DATABASE_URL']}\n\n"
print "##############################\n"

require 'sequel'
DATABASE_CONNECTION = Sequel.connect(ENV['DATABASE_URL'])
Sequel.default_timezone = :utc
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :update_or_create
Sequel::Model.plugin :validation_helpers

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
require './lib/models/daily_stats.rb'
require './lib/models/daily_user_stats.rb'
require './lib/models/daily_parcel_stats.rb'
require './lib/models/scene_list.rb'
require './lib/models/scene.rb'
require './lib/models/parcel_traffic.rb'

# require adapters
require 'faraday'
require './lib/adapters/telegram.rb'

# require jobs
require './lib/jobs/job.rb'
require './lib/jobs/fetch_peer_data.rb'
require './lib/jobs/process_snapshots.rb'
require './lib/jobs/process_snapshot.rb'
require './lib/jobs/process_user_activities.rb'
require './lib/jobs/process_all_daily_stats.rb'
require './lib/jobs/process_daily_user_activity.rb'
require './lib/jobs/process_daily_stats.rb'
require './lib/jobs/process_daily_user_stats.rb'
require './lib/jobs/process_daily_parcel_stats.rb'
require './lib/jobs/process_daily_parcel_traffic.rb'
require './lib/jobs/clean_up_transitory_data.rb'
require './lib/jobs/delete_data_points.rb'
require './lib/jobs/create_scenes.rb'
require './lib/jobs/create_daily_parcel_traffic.rb'

# require services
require './lib/services/telegram_operator.rb'
require './lib/services/process_snapshots.rb'
require './lib/services/daily_user_activity_builder.rb'
require './lib/services/daily_stats_builder.rb'
require './lib/services/daily_user_stats_builder.rb'
require './lib/services/daily_parcel_stats_builder.rb'
require './lib/services/fetch_scene_data.rb'
require './lib/services/create_scenes_on_date.rb'
require './lib/services/create_daily_parcel_traffic.rb'

# require serializers
require './lib/serializers/global/parcels.rb'
require './lib/serializers/global/users.rb'
