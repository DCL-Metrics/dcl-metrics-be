print "creating scene_disambiguations table\n"

Sequel.migration do
  change do
    create_table(:scene_disambiguations) do
      primary_key :id

      String  :uuid,            null: false
      String  :name,            null: false
      String  :coordinates,     null: false
    end

    add_index :scene_disambiguations, :uuid
    add_index :scene_disambiguations, [:name, :coordinates], unique: true
  end
end
