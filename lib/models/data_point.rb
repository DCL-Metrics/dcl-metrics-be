# primary_key :id
#
# String  :address
# String  :coordinates
# Date    :date,        null: false
# String  :peer_id
# String  :position
# String  :scene_cid
# Time    :timestamp,   null: false
#
# Time    :created_at,  null: false
#
# add_index :data_points, [:address]
# add_index :data_points, [:coordinates]
# add_index :data_points, [:date]

module Models
  class DataPoint < Sequel::Model(FAT_BOY_DATABASE[:data_points])
    def self.histogram
      FAT_BOY_DATABASE[
        "select DATE_TRUNC('day', date) as day,
        count(id)
        from data_points
        group by day
        order by 1"
      ].all
    end
  end
end

