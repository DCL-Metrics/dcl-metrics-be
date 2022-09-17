print "adding total_active_scenes to daily_stats\n"

Sequel.migration do
  change do
    add_column :daily_stats, :total_active_scenes, Integer
  end
end
