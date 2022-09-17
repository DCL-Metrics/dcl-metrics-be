print "dropping scene_list table\n"

Sequel.migration do
  change do
    drop_table(:scene_list)
  end
end
