print "creating daily_user_stats table\n"

Sequel.migration do
  change do
    create_table(:daily_user_stats) do
      primary_key :id

      Date    :date,            null: false
      String  :address,         null: false
      Integer :time_spent
      Integer :parcels_visited

      Time    :created_at,      null: false
    end

    add_index :daily_user_stats, [:date]
    add_index :daily_user_stats, [:address]
  end
end
