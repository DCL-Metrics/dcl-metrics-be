# primary_key :id
#
# Integer   :x,             null: false
# Integer   :y,             null: false
# Jsonb     :data_json,     null: false
# Time      :last_update_at
# String,   :owner
# TrueClass :active_deploy
# Time      :updated_at,    null: false
#
# add_index :parcels, [:x, :y], unique: true

module Models
  class Parcel < Sequel::Model
  end
end
