print "creating user_activities table\n"

Sequel.migration do
  change do
    create_table(:user_activities) do
      primary_key :id

      String  :name,                  null: false
      String  :address,               null: false
      String  :starting_coordinates,  null: false
      String  :starting_position,     null: false
      String  :ending_coordinates,    null: false
      String  :ending_position,       null: false
      Time    :start_time,            null: false
      Time    :end_time,              null: false
      Integer :duration,              null: false

      Time    :created_at,            null: false
    end

    add_index :user_activities, [:name]
    add_index :user_activities, [:address]
    add_index :user_activities, [:starting_coordinates]
    add_index :user_activities, [:ending_coordinates]
  end
end
