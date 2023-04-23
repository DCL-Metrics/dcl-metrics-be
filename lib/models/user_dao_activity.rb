# primary_key :id
#
# String    :address, null: false
#
# Integer   :total_vp
# Integer   :delegated_vp
# String    :delegators
# String    :delegate
#
# Integer   :votes_count
# Time      :first_vote_cast_at
# Time      :latest_vote_cast_at
#
# Jsonb     :grants_authored_json
# Integer   :grants_authored_count
#
# Jsonb     :grants_beneficiary_json
# Integer   :grants_beneficiary_count
# Integer   :total_authored_grants_requested_usd
# Integer   :total_authored_grants_enacted_usd
# Integer   :total_beneficiary_grants_requested_usd
# Integer   :total_beneficiary_grants_enacted_usd
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

    def votes
      Models::DaoVote.where(address: address)
    end

    def title
      return 'plankton' if total_vp.nil?

      vp_titles = Models::DaoGovernance.last.kpis['vp_distribution']

      case
      when total_vp > vp_titles['whales']['minimum_vp'] then 'whale'
      when total_vp > vp_titles['sharks']['minimum_vp'] then 'shark'
      when total_vp > vp_titles['dolphins']['minimum_vp'] then 'dolphin'
      when total_vp > vp_titles['fish']['minimum_vp'] then 'fish'
      when total_vp > vp_titles['crabs']['minimum_vp'] then 'crab'
      else
        'shrimp'
      end
    end

    def grants
      {
        authored: {
          count: grants_authored_count.to_i,
          total_requested_usd: total_authored_grants_requested_usd.to_i,
          total_enacted_usd: total_authored_grants_enacted_usd.to_i,
          data: JSON.parse(grants_authored_json || '[]')
        },
        beneficiary: {
          count: grants_beneficiary_count.to_i,
          total_requested_usd: total_beneficiary_grants_requested_usd.to_i,
          total_enacted_usd: total_beneficiary_grants_enacted_usd.to_i,
          data: JSON.parse(grants_beneficiary_json || '[]')
        }
      }
    end

    def recently_active?
      latest_vote_cast_at > Date.today - 7
    end
  end
end
