# primary_key :id
#
# String    :address, null: false
#
# Integer   :total_vp
# Integer   :delegated_vp
# String    :delegators
# String    :delegate_address
#
# Integer   :votes_cast
# Time      :first_vote_cast_at
# Time      :latest_vote_cast_at
#
# Integer   :proposals_authored
#
# TrueClass :collection_creator
#
# TrueClass :active_dao_committee_member
# Jsonb     :memberships_json
#
# Time    :created_at,      null: false
# Time    :updated_at,      null: false
#
# add_index :user_dao_activities, :address, unique: true
# add_index :user_dao_activities, :total_vp
# add_index :user_dao_activities, :votes_cast

module Models
  class UserDaoActivity < Sequel::Model(FAT_BOY_DATABASE[:user_dao_activities])
    one_to_one :user, key: :address

    def recently_active?
      # dao_latest_vote_at < x days ago
    end
  end
end
