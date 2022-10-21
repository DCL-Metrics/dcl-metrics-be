print "adding first_seen_on to scenes\n"

Sequel.migration do
  change do
    add_column :scenes, :first_seen_on, Date
  end
end
