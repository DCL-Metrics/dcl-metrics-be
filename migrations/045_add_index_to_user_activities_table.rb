print "adding index to user_activities table\n"

Sequel.migration do
  change do
    add_index :user_activities, [:name, :address, :start_time, :end_time], unique: true
  end
end
