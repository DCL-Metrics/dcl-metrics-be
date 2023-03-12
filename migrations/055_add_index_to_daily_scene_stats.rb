print "adding index to daily_scene_stats table\n"

Sequel.migration do
  change do
    add_index :daily_scene_stats, [:date, :scene_disambiguation_uuid]
    add_index :daily_scene_stats, :scene_disambiguation_uuid
  end
end
