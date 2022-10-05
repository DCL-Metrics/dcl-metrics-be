print "adding visitors_by_hour_histogram to daily_scene_stats\n"

Sequel.migration do
  change do
    add_column :daily_scene_stats, :visitors_by_hour_histogram_json, :jsonb
  end
end
