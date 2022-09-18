print "adding unique_visitors_afk to daily_scene_stats\n"

Sequel.migration do
  change do
    add_column :daily_scene_stats, :unique_visitors_afk, Integer
  end
end
