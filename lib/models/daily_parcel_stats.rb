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
  end
end
