print "adding columns to daily_parcel_stats\n"

Sequel.migration do
  change do
    add_column :daily_parcel_stats, :deploy_count, Integer
    add_column :daily_parcel_stats, :max_concurrent_users, Integer
    add_column :daily_parcel_stats, :scene_cid, String
  end
end
