print "creating user_dao_activities table\n"

Sequel.migration do
  change do
    create_table(:user_dao_activities) do
      primary_key :id

      String    :address, null: false

      Integer   :total_vp
      Integer   :delegated_vp
      String    :delegators
      String    :delegate_address

      Integer   :votes_cast
      Time      :first_vote_cast_at
      Time      :latest_vote_cast_at

      Integer   :proposals_authored

      TrueClass :collection_creator

      TrueClass :active_dao_committee_member
      Jsonb     :memberships_json

      Time    :created_at,      null: false
      Time    :updated_at,      null: false
    end

    add_index :user_dao_activities, :address, unique: true
    add_index :user_dao_activities, :total_vp
    add_index :user_dao_activities, :votes_cast
  end
end



