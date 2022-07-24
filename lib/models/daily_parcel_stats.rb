# primary_key :id
#
# Date    :date,            null: false
# String  :coordinates,     null: false
# Integer :avg_time_spent
# Integer :avg_time_spent_afk
# Integer :unique_visitors
# Integer :logins
# Integer :logouts
#
# Time    :created_at,      null: false
#
# add_index :daily_parcel_stats, [:date]
# add_index :daily_parcel_stats, [:coordinates]

module Models
  class DailyParcelStats < Sequel::Model
    def self.recent
      where { date >= Date.today - 7 }.order(:date)
    end

    def serialize
      {
        coordinates: coordinates,
        avg_time_spent: avg_time_spent,
        avg_time_spent_afk: avg_time_spent_afk,
        unique_visitors: unique_visitors,
        logins: logins,
        logouts: logouts
      }
    end
  end
end
