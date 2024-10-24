print "NICE\n"
print "dropping data_json column from parcels\n"

Sequel.migration do
  change do
    drop_column :parcels, :data_json
  end
end
