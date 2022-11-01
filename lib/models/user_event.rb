# primary_key :id
#
# String  :address,     null: false
# String  :coordinates, null: false
# String  :event,       null: false
# String  :position,    null: false
# Time    :timestamp,   null: false
# String  :scene_cid
#
# Time    :created_at,  null: false
#
# add_index :user_events, [:address]
# add_index :user_events, [:coordinates]
# add_index :user_events, [:event]


module Models
  class UserEvent < Sequel::Model
  end
end
