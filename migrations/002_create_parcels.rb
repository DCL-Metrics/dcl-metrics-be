print "creating parcels table\n"

Sequel.migration do
  change do
    create_table(:parcels) do
      primary_key :id

      Integer :x,           null: false
      Integer :y,           null: false
      Jsonb   :data_json,   null: false
      Time    :updated_at,  null: false
    end

    add_index :parcels, [:x, :y], unique: true
  end
end
