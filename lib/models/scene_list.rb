# primary_key :id
#
# Date    :date,        null: false
# Jsonb   :scenes_json, null: false
# Time    :created_at,  null: false
#
# add_index :scene_list, [:date], unique: true

module Models
  class SceneList < Sequel::Model(:scene_list)
    def scenes
      JSON.parse(scenes_json)
    end
  end
end
