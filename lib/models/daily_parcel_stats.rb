# primary_key :id
#
# Date    :date,            null: false
# String  :coordinates,     null: false
# Integer :avg_time_spent
# Integer :avg_time_spent_afk
# Integer :unique_visitors
# Integer :logins
# Integer :logouts
# Integer :deploy_count
# Integer ::max_concurrent_users
# Integer :scene_cid

#
# Time    :created_at,      null: false
#
# add_index :daily_parcel_stats, [:date]
# add_index :daily_parcel_stats, [:coordinates]

module Models
  class DailyParcelStats < Sequel::Model
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

    private

    def self.previous_x_days(x)
      where { date >= Date.today - x }
    end
  end
end
