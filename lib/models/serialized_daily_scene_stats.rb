# primary_key :id
#
# Date    :date,            null: false
# String  :name,            null: false
# String  :coordinates,     null: false
# Jsonb   :data_json,       null: false
#
# Time    :created_at,      null: false
#
# add_index :serialized_daily_scene_stats, :date
# add_index :serialized_daily_scene_stats, [:name, :coordinates]

# NOTE: this model holds a single serialzed daily scene stat.
# it's used to quickly gather the data required to build scene dashboards

module Models
  class SerializedDailySceneStats < Sequel::Model(FAT_BOY_DATABASE[:serialized_daily_scene_stats])
  end
end
