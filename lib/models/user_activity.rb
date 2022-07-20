# primary_key :id
#
# String  :address,     null: false
# String  :coordinates, null: false
# String  :name,        null: false
# Time    :start_time,  null: false
# Time    :end_time,    null: false
# Integer :duration,    null: false
#
# Time    :created_at,  null: false
#
# add_index :user_activities, [:address]
# add_index :user_activities, [:coordinates]

module Models
  class UserActivity < Sequel::Model
  end
end
