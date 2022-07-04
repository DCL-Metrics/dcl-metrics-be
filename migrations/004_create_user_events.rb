print "creating user_events table\n"

Sequel.migration do
  change do
    create_table(:user_events) do
      primary_key :id

      String  :address,     null: false
      String  :coordinates, null: false
      String  :event,       null: false
      Time    :timestamp,   null: false

      Time    :created_at,  null: false
    end

    add_index :user_events, [:address]
    add_index :user_events, [:coordinates]
    add_index :user_events, [:event]
  end
end
