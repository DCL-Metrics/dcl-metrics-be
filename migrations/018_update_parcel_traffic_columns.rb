print "updating columns in parcel traffic\n"

Sequel.migration do
  change do
    drop_column :parcel_traffic, :scene_cid
    add_column  :parcel_traffic, :scene_cids_json, :jsonb
  end
end
