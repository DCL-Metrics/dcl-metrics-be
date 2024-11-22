# primary_key :id
#
# Date    :date,        null: false
# Jsonb   :data_json,   null: false
# String  :coordinates, null: false
# String  :scene_cid
#
# Time    :created_at,  null: false
#
# add_index :peer_stats, [:date, :coordinates], unique: true
# add_index :peer_stats, [:coordinates]
# add_index :peer_stats, [:date]

module Models
  class PeerStats < Sequel::Model(FAT_BOY_DATABASE[:peer_stats])
    def data
      JSON.parse(data_json)
    end
  end
end
