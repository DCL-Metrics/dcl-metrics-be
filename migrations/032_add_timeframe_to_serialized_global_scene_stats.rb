print "adding timeframe to serialized_global_scene_stats\n"

Sequel.migration do
  change do
    add_column :serialized_daily_scene_stats, :timeframe, String
    drop_index :serialized_daily_scene_stats, :date
    add_index :serialized_daily_scene_stats, [:date, :timeframe], unique: true
  end
end
