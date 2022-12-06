print "updating serialized_daily_scene_stats table\n"

Sequel.migration do
  change do
    alter_table(:serialized_daily_scene_stats) do
      drop_index  [:date, :timeframe]
      drop_column :timeframe

      add_column  :name, String
      add_column  :coordinates, String

      add_index   :date
      add_index   [:name, :coordinates]
    end
  end
end
