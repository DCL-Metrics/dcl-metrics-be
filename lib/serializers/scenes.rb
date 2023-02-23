module Serializers
  class Scenes
    def self.serialize(scenes, basic_data_only: false)
      new(scenes, basic_data_only).call
    end

    def initialize(scenes, basic_data_only)
      @scenes = scenes
      @basic_data_only = basic_data_only
    end

    def call
      enriched_users = build_enriched_users unless basic_data_only

      scenes.map do |scene|
        base = {
          name: scene.name,
          uuid: scene.scene_disambiguation_uuid,
          date: scene.date.to_s,
          map_url: scene.map_url,
          visitors: scene.unique_addresses,
          share_of_global_visitors: scene.share_of_global_visitors,
          avg_time_spent: scene.avg_time_spent,
          avg_time_spent_afk: scene.avg_time_spent_afk,
          total_logins: scene.total_logins,
          unique_logins: scene.unique_logins,
          total_logouts: scene.total_logouts,
          unique_logouts: scene.unique_logouts,
          complete_sessions: scene.complete_sessions,
          avg_complete_session_duration: scene.avg_complete_session_duration,
        }

        next base if basic_data_only

        base.merge({
          marathon_users: serialize_marathon_users(scene.marathon_users, enriched_users),
          time_spent_histogram: scene.time_spent_histogram,
          visitors_by_hour_histogram: scene.visitors_by_hour_histogram,
          parcels_heatmap: scene.parcels_heatmap
        })
      end
    end

    private
    attr_reader :scenes, :basic_data_only

    def build_enriched_users
      addresses = scenes.flat_map { |scene| scene.marathon_users.keys }.uniq
      enrich_user_data(addresses)
    end

    def serialize_marathon_users(marathon_users, enriched_users)
      marathon_users.map do |address, time_spent|
        enriched_users.
          detect { |x| x[:address] == address }.
          merge(time_spent: time_spent.round)
      end
    end

    def enrich_user_data(addresses)
      users = addresses.map { |address| { address: address } }
      Services::EnrichUserData.call(users: users)
    end
  end
end
