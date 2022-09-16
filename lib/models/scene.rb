# primary_key :id
#
# String  :cid, null: false, unique: true
# String  :name
# String  :owner
# Jsonb   :parcels_json, null: false
#
# add_index :scenes, [:cid]

module Models
  class Scene < Sequel::Model
    def parcels
      JSON.parse(parcels_json)
    end
  end
end

