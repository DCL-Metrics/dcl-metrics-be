print "updating columns in parcel_traffic\n"

Sequel.migration do
  change do
    drop_column :parcel_traffic, :scene_cids_json
    drop_column :parcel_traffic, :data_ndj

    add_column  :parcel_traffic, :scene_cid, String
  end
end
