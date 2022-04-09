print "creating peers_dump table\n"

Sequel.migration do
  change do
    create_table(:peers_dump) do
      primary_key :id

      Jsonb   :data_json,   null: false
      Time    :created_at,  null: false
    end

    add_index :peers_dump, [:created_at], unique: true
  end
end
