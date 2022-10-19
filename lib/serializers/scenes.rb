module Serializers
  class Scenes
    def self.serialize(scenes)
      new(scenes).call
    end

    def initialize(scenes)
      @scenes = scenes
    end

    def call
      scenes.map do |scene|
        {
          name: scene.name,
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
          marathon_users: enrich_user_data(scene.marathon_users),
          time_spent_histogram: scene.time_spent_histogram,
          visitors_by_hour_histogram: scene.visitors_by_hour_histogram,
          parcels_heatmap: scene.parcels_heatmap
        }
      end
    end

    private
    attr_reader :scenes

    def enrich_user_data(users)
      formatted_users = users.map { |k,v| { address: k, time_spent: v } }
      Services::EnrichUserData.call(users: formatted_users)
    end
  end
end
