# primary_key :id
#
# Jsonb   :collections_json
# Time    :collections_updated_at
#
# Jsonb   :grants_json
# Time    :grants_updated_at
#
# Jsonb   :kpis_json
# Time    :kpis_updated_at
#
# Jsonb   :members_json
# Time    :members_updated_at
#
# Jsonb   :proposals_json
# Time    :proposals_updated_at
#
# Jsonb   :team_json
# Time    :team_updated_at

module Models
  class DaoGovernance < Sequel::Model(FAT_BOY_DATABASE[:dao_governance])
    def timestamps
      {
        collections: collections_updated_at,
        grants: grants_updated_at,
        kpis: kpis_updated_at,
        members: members_updated_at,
        proposals: proposals_updated_at,
        team: team_updated_at
      }
    end

    def collections
      @collections ||= JSON.parse(collections_json)
    end

    def grants
      @grants ||= JSON.parse(grants_json)
    end

    def kpis
      @kpis ||= JSON.parse(kpis_json)
    end

    def members
      @members ||= JSON.parse(members_json)
    end

    def proposals
      @proposals ||= JSON.parse(proposals_json)
    end

    def team
      @team ||= JSON.parse(team_json)
    end
  end
end
