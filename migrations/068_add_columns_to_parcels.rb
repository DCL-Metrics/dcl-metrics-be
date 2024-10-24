print "add columns to parcels table\n"

Sequel.migration do
  change do
    add_column :parcels, :last_update_at, Time
    add_column :parcels, :owner, String
    add_column :parcels, :active_deploy, TrueClass
  end
end
