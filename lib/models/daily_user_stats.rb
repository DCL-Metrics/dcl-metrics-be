# primary_key :id
#
# Date    :date,            null: false
# String  :address,         null: false
# Integer :time_spent,      null: false
# Integer :parcels_visited, null: false
#
# Time    :created_at,      null: false
#
# add_index :daily_user_stats, [:date]
# add_index :daily_user_stats, [:address]

module Models
  class DailyUserStats < Sequel::Model
  end
end
