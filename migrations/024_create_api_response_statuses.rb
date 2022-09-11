print "creating api_response_statuses table\n"

Sequel.migration do
  change do
    create_table(:api_response_statuses) do
      primary_key :id

      Date    :date,            null: false
      String  :url,             null: false
      Jsonb   :responses_json,  null: false
      Integer :success_count,   null: false, default: 0
      Integer :failure_count,   null: false, default: 0

      Time    :created_at,      null: false
    end

    add_index :api_response_statuses, [:date]
    add_index :api_response_statuses, [:url]
    add_index :api_response_statuses, [:date, :url], unique: true
  end
end
