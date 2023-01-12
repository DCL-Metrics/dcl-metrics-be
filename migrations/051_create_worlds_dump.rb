print "creating worlds_dump table\n"

Sequel.migration do
  change do
    create_table(:worlds_dump) do
      primary_key :id

      Jsonb   :data_json,   null: false
      Time    :created_at,  null: false
    end

    add_index :worlds_dump, :created_at, unique: true
  end
end
