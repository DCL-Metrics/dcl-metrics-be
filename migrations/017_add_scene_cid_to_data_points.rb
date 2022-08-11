print "adding scene_cid to data_points\n"

Sequel.migration do
  change do
    add_column :data_points, :scene_cid, String
  end
end
