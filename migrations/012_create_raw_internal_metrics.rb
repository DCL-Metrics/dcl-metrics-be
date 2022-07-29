print "creating raw_internal_metrics table\n"

Sequel.migration do
  change do
    create_table(:raw_internal_metrics) do
      primary_key :id

      Date   :date,         null: false
      String :endpoint,     null: false
      Jsonb  :metrics_json, null: false

      Time   :created_at,   null: false
    end

    add_index :raw_internal_metrics, [:date]
    add_index :raw_internal_metrics, [:endpoint]
  end
end
