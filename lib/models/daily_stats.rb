# primary_key :id
#
# Date    :date,                  null: false
# Integer :unique_users,          null: false
# Integer :total_active_parcels,  null: false
# Integer :total_active_scenes,  null: false
#
# Time    :created_at,            null: false
#
# add_index :daily_stats, [:date]

module Models
  class DailyStats < Sequel::Model
    def self.last_month
      previous_x_days(30)
    end

    def self.last_quarter
      previous_x_days(90)
    end

    def serialize
      {
        unique_users: unique_users,
        active_parcels: total_active_parcels,
        active_scenes: total_active_scenes
      }
    end

    private

    def self.previous_x_days(x)
      where { date >= Date.today - x }
    end
  end
end
