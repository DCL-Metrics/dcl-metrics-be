# primary_key :id
#
# Date    :date,      null: false
# Jsonb   :data_json, null: false
#
# Time :created_at, null: false
# Time :updated_at, null: false
#
# add_index :serialized_daily_parcel_stats, :date, unique: true

# NOTE: this model holds an entire days worth of serialized parcel stats in one
# big JSON. it's used for building the heatmaps in the landpicker.

module Models
  class SerializedDailyParcelStats < Sequel::Model(FAT_BOY_DATABASE[:serialized_daily_parcel_stats])
  end
end
