print "add time_spent_afk to daily_user_stats table\n"

Sequel.migration do
  change do
    add_column :daily_user_stats, :time_spent_afk, Integer
  end
end
