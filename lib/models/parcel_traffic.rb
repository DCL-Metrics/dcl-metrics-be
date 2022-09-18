# primary_key :id
#
# String  :coordinates, null: false
# Date    :date,        null: false
# Text    :data_ndj,    null: false
# Jsonb   :scene_cids_json
# Jsonb   :addresses_json
# Jsonb   :histogram_json
# Integer :unique_addresses
#
# Time    :created_at,  null: false
#
# add_index :parcel_traffic, [:coordinates]
# add_index :parcel_traffic, [:date]
# add_index :parcel_traffic, [:scene_cid]
# add_index :parcel_traffic, [:coordinates, :date], unique: true

module Models
  class ParcelTraffic < Sequel::Model(:parcel_traffic)
    # TODO: need custom way to load data that doesn't blow up the server
    def scenes
      Models::Scene.where(cid: JSON.parse(scene_cids_json))
    end

    def addresses
      @addresses ||= Json.parse(addresses_json)
    end
  end
end
