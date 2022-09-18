# primary_key :id
#
# Date    :date,            null: false
# String  :name,            null: false
# String  :coordinates,     null: false
# String  :cids,            null: false
# Integer :total_visitors
# Integer :unique_visitors
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
# Jsonb   :parcels_heatmap_json
#
# Time    :created_at,      null: false
#
# add_index :daily_scene_stats, [:date]
# add_index :daily_scene_stats, [:coordinates]

module Models
  class DailySceneStats < Sequel::Model
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

    def marathon_users
      JSON.parse(visitors_by_total_time_spent_json).
        sort_by(&:last).
        last(10).
        reverse.
        to_h
    end

    private

    def self.previous_x_days(x)
      where { date >= Date.today - x }
    end
  end
end
