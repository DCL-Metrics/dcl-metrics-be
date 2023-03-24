print "changing columns of user_dao activities\n"

Sequel.migration do
  change do
    rename_column :user_dao_activities, :delegate_address, :delegate
    rename_column :user_dao_activities, :votes_cast, :votes_count
    rename_column :user_dao_activities, :proposals_authored, :proposals_count
    rename_column :user_dao_activities, :memberships_json, :teams_json

    add_column :user_dao_activities, :proposals_json, 'jsonb'
    add_column :user_dao_activities, :collections_json, 'jsonb'
    add_column :user_dao_activities, :grants_authored_json, 'jsonb'
    add_column :user_dao_activities, :grants_beneficiary_json, 'jsonb'

    add_column :user_dao_activities, :grants_authored_count, Integer
    add_column :user_dao_activities, :grants_beneficiary_count, Integer
  end
end
