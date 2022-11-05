print "updating index on peer_stats table\n"

Sequel.migration do
  change do
    alter_table(:parcel_traffic) do
      drop_index [:coordinates, :date]
      add_index [:coordinates, :date, :scene_cid], unique: true
    end
  end
end
