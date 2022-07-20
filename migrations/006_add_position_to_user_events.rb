print "adding position to user_events\n"

Sequel.migration do
  change do
    add_column :user_events, :position, String
  end
end
