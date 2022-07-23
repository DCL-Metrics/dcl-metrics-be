print "adding date to user_activities\n"

Sequel.migration do
  change do
    add_column :user_activities, :date, Date
  end
end
