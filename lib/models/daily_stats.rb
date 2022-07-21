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
  end
end
