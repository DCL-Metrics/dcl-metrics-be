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

    def self.yesterday
      previous_x_days(1)
    end

    def self.last_week
      previous_x_days(7)
    end

    def self.last_month
      previous_x_days(30)
    end

    def serialize
      {
        address: address,
        time_spent: time_spent,
        parcels_visited: parcels_visited
      }
    end

    private

    def self.previous_x_days(x)
      where { date >= Date.today - x }
    end
  end
end
