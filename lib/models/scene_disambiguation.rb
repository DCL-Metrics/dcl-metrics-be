# primary_key :id
#
# String  :uuid,            null: false
# String  :name,            null: false
# String  :coordinates,     null: false
#
# add_index :scene_disambiguations, :uuid
# add_index :scene_disambiguations, [:name, :coordinates], unique: true

module Models
  class SceneDisambiguation < Sequel::Model
    def first_deployed_at
      scenes.order(:first_seen_at).first
    end

    def scenes
      Models::Scene.where(scene_disambiguation_uuid: uuid)
    end
  end
end
