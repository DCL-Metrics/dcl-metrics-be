print "dropping scenes#parcels_json\n"

Sequel.migration do
  change do
    drop_column :scenes, :parcels_json
  end
end
