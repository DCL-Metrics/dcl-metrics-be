print "adding scenes_visited to daily_user_stats\n"

Sequel.migration do
  change do
    add_column :daily_user_stats, :scenes_visited, Integer
  end
end
