print "updating ndj columns in parcel traffic\n"

Sequel.migration do
  change do
    rename_column :parcel_traffic, :addresses_ndj, :addresses_json
    drop_column   :parcel_traffic, :data_ndj
    add_column    :parcel_traffic, :data_ndj, :text
  end
end
