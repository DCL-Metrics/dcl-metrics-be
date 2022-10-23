# primary_key :id
#
# String  :name,                  null: false
# String  :address,               null: false
# String  :starting_coordinates,  null: false
# String  :starting_position,     null: false
# String  :ending_coordinates,    null: false
# String  :ending_position,       null: false
# Time    :start_time,            null: false
# Time    :end_time,              null: false
# Integer :duration,              null: false
#
# Time    :created_at,            null: false
#
# add_index :user_activities, [:name]
# add_index :user_activities, [:address]
# add_index :user_activities, [:starting_coordinates]
# add_index :user_activities, [:ending_coordinates]

module Models
  class UserActivity < Sequel::Model(FAT_BOY_DATABASE[:user_activities])
    def validate
      super
      validates_unique([:name, :address, :start_time, :end_time])
    end
  end
end
