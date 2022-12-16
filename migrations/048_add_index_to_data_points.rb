print "adding index to data_points table\n"

Sequel.migration do
  change do
    add_index :data_points, [:coordinates, :scene_cid, :date]
    add_index :data_points, [:coordinates, :date]
  end
end
