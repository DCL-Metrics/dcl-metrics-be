print "adding first_seen_on to user_activities\n"

Sequel.migration do
  change do
    add_column :scenes, :first_seen_on, Date
  end
end
