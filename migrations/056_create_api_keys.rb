print "creating api_keys table\n"

Sequel.migration do
  change do
    create_table(:api_keys) do
      primary_key :id

      String  :key,               null: false
      Jsonb   :permissions_json,  default: "{}"
      Time    :expires_at,        null: false

      Time    :created_at,        null: false
      Time    :updated_at,        null: false
    end

    add_index :api_keys, :key, unique: true
  end
end
