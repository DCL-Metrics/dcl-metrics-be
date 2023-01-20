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
  end
end
