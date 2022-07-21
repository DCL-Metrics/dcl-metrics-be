print "creating daily_stats table\n"

Sequel.migration do
  change do
    create_table(:daily_stats) do
      primary_key :id

      Date    :date,                  null: false
      Integer :unique_users,          null: false
      Integer :total_active_parcels,  null: false

      Time    :created_at,            null: false
    end

    add_index :daily_stats, [:date]
  end
end
