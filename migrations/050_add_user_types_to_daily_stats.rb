print "add columns to daily_stats table\n"

Sequel.migration do
  change do
    add_column :daily_stats :guest_users, Integer
    add_column :daily_stats :named_users, Integer
    add_column :daily_stats :new_users, Integer
  end
end
