print "updates index on peer_stats table\n"

Sequel.migration do
  change do
    alter_table(:peer_stats) do
      drop_index [:date, :coordinates]
      add_index [:date, :coordinates, :scene_cid], unique: true
    end
  end
end
