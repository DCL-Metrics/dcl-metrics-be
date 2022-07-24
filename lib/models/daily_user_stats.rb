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
    def self.recent
      where { date >= Date.today - 7 }.order(:date)
    end

    def serialize
      {
        date: date.to_s,
        address: unique_users,
        time_spent: time_spent,
        parcels_visited: parcels_visited
      }
    end
  end
end
