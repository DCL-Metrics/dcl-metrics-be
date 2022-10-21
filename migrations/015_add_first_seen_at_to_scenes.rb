print "adding first_seen_at to scenes\n"

Sequel.migration do
  change do
    add_column :scenes, :first_seen_at, Time
  end
end
