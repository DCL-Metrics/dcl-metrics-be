# primary_key :id
#
# Date    :date,                  null: false
# Integer :unique_users,          null: false
# Integer :total_active_parcels,  null: false
#
# Time    :created_at,            null: false
#
# add_index :daily_stats, [:date]

module Models
  class DailyStats < Sequel::Model
    def self.recent
      where { date >= Date.today - 7 }.order(:date)
    end

    def serialize
      {
        date: date.to_s,
        unique_users: unique_users,
        active_parcels: total_active_parcels
      }
    end
  end
end
