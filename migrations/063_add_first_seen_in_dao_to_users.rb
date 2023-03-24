print "add first_seen_in_dao to users table\n"

Sequel.migration do
  change do
    add_column :users, :first_seen_in_dao, TrueClass
  end
end
