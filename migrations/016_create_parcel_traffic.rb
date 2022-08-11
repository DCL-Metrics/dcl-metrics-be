print "creating parcel_traffic table\n"

Sequel.migration do
  change do
    create_table(:parcel_traffic) do
      primary_key :id

      String  :coordinates, null: false
      Date    :date,        null: false
      Jsonb   :data_ndj,    null: false
      String  :scene_cid
      Jsonb   :addresses_ndj
      Jsonb   :histogram_json

      Time    :created_at,  null: false
    end

    add_index :parcel_traffic, [:coordinates]
    add_index :parcel_traffic, [:date]
    add_index :parcel_traffic, [:scene_cid]
    add_index :parcel_traffic, [:coordinates, :date], unique: true
  end
end
