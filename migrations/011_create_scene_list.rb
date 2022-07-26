print "creating scene_list table\n"

Sequel.migration do
  change do
    create_table(:scene_list) do
      primary_key :id

      Date    :date,        null: false
      Jsonb   :scenes_json, null: false
      Time    :created_at,  null: false
    end

    add_index :scene_list, [:date], unique: true
  end
end
