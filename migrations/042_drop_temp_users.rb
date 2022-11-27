print "dropping temp_users table\n"

Sequel.migration do
  change do
    drop_table(:temp_users)
  end
end
