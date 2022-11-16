print "creating users table\n"

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id

      String    :address, null: false
      String    :avatar_url
      String    :name
      TrueClass :guest

      Date      :first_seen, null: false
      Date      :last_seen

      Time    :created_at,      null: false
      Time    :updated_at,      null: false
    end

    add_index :users, :address, unique: true
    add_index :users, :first_seen
  end
end
