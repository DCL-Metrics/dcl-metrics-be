print "adding max_concurrent_users to parcel_traffic\n"

Sequel.migration do
  change do
    add_column :parcel_traffic, :max_concurrent_users, Integer
  end
end
