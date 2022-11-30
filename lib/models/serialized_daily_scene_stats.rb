# primary_key :id
#
# Date    :date,            null: false
# String  :timeframe
# Jsonb   :data_json,       null: false
#
# Time    :created_at,      null: false
#
# add_index :serialized_daily_scene_stats, [:date, :timeframe], unique: true

module Models
  class SerializedDailySceneStats < Sequel::Model
    def data
      JSON.parse(data_json)
    end
  end
end
