print "creating daily_scene_stats table\n"

Sequel.migration do
  change do
    create_table(:daily_scene_stats) do
      primary_key :id

      Date    :date,            null: false
      String  :name,            null: false
      String  :coordinates,     null: false
      String  :cids,            null: false
      Integer :total_visitors
      Integer :unique_visitors
      Integer :unique_addresses
      Integer :share_of_global_visitors
      Integer :avg_time_spent
      Integer :avg_time_spent_afk
      Integer :percent_of_users_afk
      Integer :total_logins
      Integer :unique_logins
      Integer :total_logouts
      Integer :unique_logouts
      Integer :complete_sessions
      Integer :avg_complete_session_duration

      Jsonb   :visitors_by_total_time_spent_json
      Jsonb   :visitors_total_time_spent_histogram_json
      Jsonb   :parcels_heatmap_json

      Time    :created_at,      null: false
    end

    add_index :daily_scene_stats, [:date]
    add_index :daily_scene_stats, [:coordinates]
  end
end
