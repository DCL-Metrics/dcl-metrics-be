print "creating temp_users table\n"

Sequel.migration do
  change do
    create_table(:temp_users) do
      primary_key :id

      String    :address, null: false
      String    :avatar_url
      String    :name
      TrueClass :guest
      TrueClass :verified

      Time    :created_at,      null: false
    end

    add_index :temp_users, :address, unique: true
  end
end
