print "creating api_key_access_logs table\n"

Sequel.migration do
  change do
    create_table(:api_key_access_logs) do
      primary_key :id

      String  :key,               null: false
      String  :endpoint,          null: false
      String  :ip_address,        null: false
      Jsonb   :query_params_json, default: "{}"
      Integer :response,          null: false

      Time    :created_at,        null: false
    end

    add_index :api_key_access_logs, :key
    add_index :api_key_access_logs, :endpoint
    add_index :api_key_access_logs, :ip_address
  end
end
