# primary_key :id
#
# String  :coordinates, null: false
# Date    :date,        null: false
# String  :scene_cid
# Jsonb   :addresses_json
# Jsonb   :histogram_json
# Integer :unique_addresses
#
# Time    :created_at,  null: false
#
# add_index :parcel_traffic, [:coordinates]
# add_index :parcel_traffic, [:date]
# add_index :parcel_traffic, [:scene_cid]
# add_index :parcel_traffic, [:coordinates, :date, :scene_cid], unique: true

module Models
  class ParcelTraffic < Sequel::Model(:parcel_traffic)
    def addresses
      @addresses ||= JSON.parse(addresses_json)
    end
  end
end
