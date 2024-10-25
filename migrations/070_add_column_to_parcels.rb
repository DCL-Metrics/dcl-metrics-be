print "add columns to parcels table\n"

Sequel.migration do
  change do
    add_column :parcels, :utilization_last_checked_at, Time
  end
end
