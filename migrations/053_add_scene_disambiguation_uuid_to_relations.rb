print "adding scene_disambituation#uuid to relations\n"

Sequel.migration do
  change do
    add_column :scenes, :scene_disambiguation_uuid, String
    add_column :daily_scene_stats, :scene_disambiguation_uuid, String
  end
end
