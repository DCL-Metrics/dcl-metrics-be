print "creating scenes table\n"

Sequel.migration do
  change do
    create_table(:scenes) do
      primary_key :id

      String  :cid, null: false, unique: true
      String  :name
      String  :owner
      Jsonb   :parcels, null: false
    end

    add_index :scenes, [:cid]
  end
end
