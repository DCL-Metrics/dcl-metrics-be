# primary_key :id
#
# String    :address, null: false
#
# Integer   :total_vp
# Integer   :delegated_vp
# String    :delegators
# String    :delegate
#
# Jsonb     :votes_json
# Integer   :votes_count
# Time      :first_vote_cast_at
# Time      :latest_vote_cast_at
#
# Jsonb     :grants_authored_json
# Integer   :grants_authored_count
#
# Jsonb     :grants_beneficiary_json
# Integer   :grants_beneficiary_count
#
# Jsonb     :proposals_json
# Integer   :proposals_count
#
# Jsonb     :collections_json
# TrueClass :collection_creator
#
# TrueClass :active_dao_committee_member
# Jsonb     :teams_json
#
# Time    :created_at,      null: false
# Time    :updated_at,      null: false
#
# add_index :user_dao_activities, :address, unique: true
# add_index :user_dao_activities, :total_vp
# add_index :user_dao_activities, :votes_cast

module Models
  class UserDaoActivity < Sequel::Model(FAT_BOY_DATABASE[:user_dao_activities])
    def user
      Models::User.find(address: address)
    end

    def recently_active?
      # dao_latest_vote_at < x days ago
    end
  end
end
