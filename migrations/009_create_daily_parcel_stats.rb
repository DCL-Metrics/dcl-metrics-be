print "creating daily_parcel_stats table\n"

Sequel.migration do
  change do
    create_table(:daily_parcel_stats) do
      primary_key :id

      Date    :date,            null: false
      String  :coordinates,     null: false
      Integer :avg_time_spent
      Integer :avg_time_spent_afk
      Integer :unique_visitors
      Integer :logins
      Integer :logouts

      Time    :created_at,      null: false
    end

    add_index :daily_parcel_stats, [:date]
    add_index :daily_parcel_stats, [:coordinates]
  end
end
