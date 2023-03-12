print "dropping serialized_daily_scene_stats table\n"

Sequel.migration do
  change do
    drop_table(:serialized_daily_scene_stats)
  end
end
