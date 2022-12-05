print "creating serialized_daily_parcel_stats table\n"

Sequel.migration do
  change do
    create_table(:serialized_daily_parcel_stats) do
      primary_key :id

      Date  :date,      null: false
      Jsonb :data_json, null: false

      Time :created_at, null: false
      Time :updated_at, null: false
    end

    add_index :serialized_daily_parcel_stats, :date, unique: true
  end
end
