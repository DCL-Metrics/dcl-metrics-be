print "creating peer_stats table\n"

Sequel.migration do
  change do
    create_table(:peer_stats) do
      primary_key :id

      Date    :date,        null: false
      Jsonb   :data_json,   null: false
      String  :coordinates, null: false
      String  :scene_cid

      Time    :created_at,  null: false
    end

    add_index :peer_stats, [:date, :coordinates], unique: true
    add_index :peer_stats, [:coordinates]
    add_index :peer_stats, [:date]
  end
end
