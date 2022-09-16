print "updating parcel column in scenes\n"

Sequel.migration do
  change do
    rename_column :scenes, :parcels, :parcels_json
  end
end
