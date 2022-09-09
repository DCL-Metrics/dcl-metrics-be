print "adding unique_addresses to parcel_traffic\n"

Sequel.migration do
  change do
    add_column :parcel_traffic, :unique_addresses, Integer
  end
end
