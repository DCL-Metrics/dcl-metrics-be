# primary_key :id
#
# Date    :date,      null: false
# Jsonb   :data_json, null: false
#
# Time :created_at, null: false
# Time :updated_at, null: false
#
# add_index :serialized_daily_parcel_stats, :date, unique: true

module Models
  class SerializedDailyParcelStats < Sequel::Model(FAT_BOY_DATABASE[:serialized_daily_parcel_stats])
  end
end
