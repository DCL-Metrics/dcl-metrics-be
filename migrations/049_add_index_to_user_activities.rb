print "adding index to user_activities table\n"

Sequel.migration do
  change do
    add_index :user_activities, [:date, :starting_coordinates, :name]
    add_index :user_activities, [:date, :ending_coordinates, :name]
    add_index :user_activities, [:date, :starting_coordinates]
    add_index :user_activities, [:date, :ending_coordinates]
  end
end
