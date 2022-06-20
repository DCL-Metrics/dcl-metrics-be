print "creating data_points table\n"

Sequel.migration do
  change do
    create_table(:data_points) do
      primary_key :id

      String  :address
      String  :coordinates
      Date    :date,        null: false
      String  :peer_id
      String  :position
      Time    :timestamp,   null: false

      Time    :created_at,  null: false
    end

    add_index :data_points, [:address]
    add_index :data_points, [:coordinates]
    add_index :data_points, [:date]
  end
end
