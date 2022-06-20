# primary_key :id
#
# String  :address
# String  :coordinates
# Date    :date,        null: false
# String  :peer_id
# String  :position
# Time    :timestamp,   null: false
#
# Time    :created_at,  null: false
#
# add_index :data_points, [:address]
# add_index :data_points, [:coordinates]
# add_index :data_points, [:date]

module Models
  class DataPoint < Sequel::Model
  end
end

