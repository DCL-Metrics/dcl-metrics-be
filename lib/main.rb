print "##############################\n\n"
print "DATABASE:  #{ENV['DATABASE_URL']}\n"
print "FAT_BOY_DATABASE:  #{ENV['FAT_BOY_DATABASE_URL']}\n\n"
print "##############################\n"

require 'sequel'
Sequel.default_timezone = :utc
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :update_or_create
Sequel::Model.plugin :validation_helpers

# NOTE: unused currently but for tests
if ENV['RACK_ENV'] == 'test'
  DATABASE_CONNECTION = Sequel.connect(
    ENV['DATABASE_URL'],
    pool_timeout: ENV['DATABASE_POOL_TIMEOUT'].to_i)
end

FAT_BOY_DATABASE = Sequel.connect(
  ENV['FAT_BOY_DATABASE_URL'],
  pool_timeout: ENV['DATABASE_POOL_TIMEOUT'].to_i)

# misc
require 'csv'
require 'json'
require 'dry/monads'
require './lib/monkey_patches.rb'

# global constants
PUBLIC_ROADS = JSON.parse(File.read('./lib/static/roads.json'))

# require models
require './lib/models/peers_dump.rb'
require './lib/models/peer_stats.rb'
require './lib/models/worlds_dump.rb'
require './lib/models/data_point.rb'
require './lib/models/user_event.rb'
require './lib/models/user_activity.rb'
require './lib/models/parcel.rb'
require './lib/models/scene.rb'
require './lib/models/daily_stats.rb'
require './lib/models/daily_user_stats.rb'
require './lib/models/daily_parcel_stats.rb'
require './lib/models/daily_scene_stats.rb'
require './lib/models/parcel_traffic.rb'
require './lib/models/api_response_status.rb'
require './lib/models/serialized_daily_parcel_stats.rb'
require './lib/models/dao_governance.rb'
require './lib/models/dao_vote.rb'
require './lib/models/user.rb'
require './lib/models/user_dao_activity.rb'
require './lib/models/user_nfts.rb'
require './lib/models/scene_disambiguation.rb'
require './lib/models/api_key.rb'
require './lib/models/api_key_access_log.rb'
require './lib/models/event.rb'

# require adapters
require 'faraday'
require './lib/adapters/base.rb'
require './lib/adapters/dcl/peers.rb'
require './lib/adapters/dcl/scenes.rb'
require './lib/adapters/dcl/user_profiles.rb'
require './lib/adapters/dcl/nft_data.rb'
require './lib/adapters/dcl/worlds.rb'
require './lib/adapters/atlas_corp/peers.rb'
require './lib/adapters/telegram.rb'
require './lib/adapters/dcl/dao_transparency/client.rb'
require './lib/adapters/dcl/dao_transparency/kpi_client.rb'
require './lib/adapters/dcl/dao_transparency/team_client.rb'
require './lib/adapters/dcl/dao_transparency/kpis.rb'
require './lib/adapters/dcl/dao_transparency/members.rb'
require './lib/adapters/dcl/dao_transparency/votes.rb'
require './lib/adapters/dcl/dao_transparency/proposals.rb'
require './lib/adapters/dcl/dao_transparency/projects.rb'
require './lib/adapters/dcl/dao_transparency/collections.rb'
require './lib/adapters/dcl/dao_transparency/team.rb'
require './lib/adapters/backblaze/read_file.rb'

# require services
require './lib/services/telegram_operator.rb'
require './lib/services/process_snapshots.rb'
require './lib/services/daily_user_activity_builder.rb'
require './lib/services/daily_stats_builder.rb'
require './lib/services/daily_user_stats_builder.rb'
require './lib/services/daily_parcel_stats_builder.rb'
require './lib/services/daily_scene_stats_builder.rb'
require './lib/services/fetch_scene_data.rb'
require './lib/services/create_daily_parcel_traffic.rb'
require './lib/services/request_logger.rb'
require './lib/services/daily_data_assessor.rb'
require './lib/services/enrich_user_data.rb'
require './lib/services/create_api_key.rb'

# require serializers
require './lib/serializers/global/daily_stats.rb'
require './lib/serializers/global/parcels.rb'
require './lib/serializers/global/scenes.rb'
require './lib/serializers/global/users.rb'
require './lib/serializers/peer_status.rb'
require './lib/serializers/parcels.rb'
require './lib/serializers/scenes.rb'
require './lib/serializers/user.rb'

# sidekiq configuration
require 'sidekiq'
require './lib/middleware/sidekiq_error_notifications.rb'

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

  config.server_middleware do |chain|
    chain.add Middleware::SidekiqErrorNotifications
  end
end

# require jobs
require './lib/jobs/job.rb'
require './lib/jobs/fetch_peer_data.rb'
require './lib/jobs/fetch_peer_stats.rb'
require './lib/jobs/fetch_worlds_data.rb'
require './lib/jobs/process_snapshot.rb'
require './lib/jobs/process_users_in_snapshot.rb'
require './lib/jobs/process_user_activities.rb'
require './lib/jobs/process_all_daily_stats.rb'
require './lib/jobs/process_dao_activities.rb'
require './lib/jobs/process_dao_activity.rb'
require './lib/jobs/process_daily_user_activity.rb'
require './lib/jobs/process_daily_stats.rb'
require './lib/jobs/process_daily_user_stats.rb'
require './lib/jobs/process_daily_parcel_stats.rb'
require './lib/jobs/process_parcel_stats.rb'
require './lib/jobs/process_daily_scene_stats.rb'
require './lib/jobs/process_daily_parcel_traffic.rb'
require './lib/jobs/process_users_by_address_batch.rb'
require './lib/jobs/process_user.rb'
require './lib/jobs/process_users_nfts.rb'
require './lib/jobs/process_user_nfts.rb'
require './lib/jobs/create_daily_parcel_traffic.rb'
require './lib/jobs/export_data_to_staging_db.rb'
require './lib/jobs/serialize_daily_parcel_stats.rb'
require './lib/jobs/user_dao_activities/collections.rb'
require './lib/jobs/user_dao_activities/projects.rb'
require './lib/jobs/user_dao_activities/members.rb'
require './lib/jobs/user_dao_activities/proposals.rb'
require './lib/jobs/user_dao_activities/team.rb'
require './lib/jobs/user_dao_activities/votes.rb'
require './lib/jobs/archive_data_points.rb'
require './lib/jobs/archive_user_activities.rb'
require './lib/jobs/archive_peers_dump.rb'
require './lib/jobs/dump_global_worlds_metrics.rb'
require './lib/jobs/create_dao_vote.rb'
require './lib/jobs/dump_global_unique_daily_metrics.rb'
require './lib/jobs/fetch_scene_utilization.rb'
require './lib/jobs/save_scene_utilization.rb'
