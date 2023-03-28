print "add requested and enacted data to user_dao_activities table\n"

Sequel.migration do
  change do
    add_column :user_dao_activities, :total_authored_grants_requested_usd, Integer
    add_column :user_dao_activities, :total_authored_grants_enacted_usd, Integer
    add_column :user_dao_activities, :total_beneficiary_grants_requested_usd, Integer
    add_column :user_dao_activities, :total_beneficiary_grants_enacted_usd, Integer
  end
end
