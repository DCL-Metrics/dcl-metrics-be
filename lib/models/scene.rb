# primary_key :id
#
# String  :cid, null: false, unique: true
# String  :name
# String  :owner
# Jsonb   :parcels, null: false
#
# add_index :scenes, [:cid]

module Models
  class Scene < Sequel::Model
  end
end

