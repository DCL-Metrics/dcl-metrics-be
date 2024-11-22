# primary_key :id
#
# Date    :date,            null: false
# String  :name,            null: false
# String  :coordinates,     null: false
# String  :cids,            null: false
# String  :scene_disambiguation_uuid
# Integer :total_visitors
# Integer :unique_visitors
# Integer :unique_visitors_afk
# Integer :unique_addresses
# Integer :share_of_global_visitors
# Integer :avg_time_spent
# Integer :avg_time_spent_afk
# Integer :percent_of_users_afk
# Integer :total_logins
# Integer :unique_logins
# Integer :total_logouts
# Integer :unique_logouts
# Integer :complete_sessions
# Integer :avg_complete_session_duration
#
# Jsonb   :visitors_by_total_time_spent_json
# Jsonb   :visitors_total_time_spent_histogram_json
# Jsonb   :visitors_by_hour_histogram_json
# Jsonb   :parcels_heatmap_json
#
# Time    :created_at,      null: false
#
# add_index :daily_scene_stats, [:date]
# add_index :daily_scene_stats, [:coordinates]

module Models
  class DailySceneStats < Sequel::Model(FAT_BOY_DATABASE[:daily_scene_stats])
    def self.yesterday
      previous_x_days(1)
    end

    def self.last_week
      previous_x_days(7)
    end

    def self.last_month
      previous_x_days(30)
    end

    def self.last_quarter
      previous_x_days(90)
    end

    def self.basic_data
      select(
        :name,
        :scene_disambiguation_uuid,
        :date,
        :coordinates,
        :unique_addresses,
        :share_of_global_visitors,
        :avg_time_spent,
        :avg_time_spent_afk,
        :total_logins,
        :unique_logins,
        :total_logouts,
        :unique_logouts,
        :complete_sessions,
        :avg_complete_session_duration
      )
    end

    def self.null_object(date:, name:, coordinates:, cids:, uuid:)
      new(
        date: date,
        name: name,
        coordinates: coordinates,
        cids: cids,
        scene_disambiguation_uuid: uuid,
        total_visitors: 0,
        unique_visitors: 0,
        unique_visitors_afk: 0,
        unique_addresses: 0,
        share_of_global_visitors: 0,
        avg_time_spent: 0,
        avg_time_spent_afk: 0,
        percent_of_users_afk: 0,
        total_logins: 0,
        unique_logins: 0,
        total_logouts: 0,
        unique_logouts: 0,
        complete_sessions: 0,
        avg_complete_session_duration: 0,
        visitors_by_total_time_spent_json: '{}',
        visitors_total_time_spent_histogram_json: '{}',
        visitors_by_hour_histogram_json: '{}',
        parcels_heatmap_json: '{}'
      )
    end

    def marathon_users
      JSON.parse(visitors_by_total_time_spent_json).
        sort_by(&:last).
        last(10).
        reverse.
        to_h
    end

    def map_url
      center = coordinates.split(';').first
      selected = coordinates

      "https://api.decentraland.org/v2/map.png?center=#{center}&selected=#{selected}"
    end

    def time_spent_histogram
      JSON.parse(visitors_total_time_spent_histogram_json)
    end

    def visitors_by_hour_histogram
      JSON.parse(visitors_by_hour_histogram_json)
    end

    def parcels_heatmap
      JSON.parse(parcels_heatmap_json)
    end

    private

    def self.previous_x_days(x)
      where { date >= Date.today - x }
    end
  end
end
