print "creating dao_governance table\n"

Sequel.migration do
  change do
    create_table(:dao_governance) do
      primary_key :id

      Jsonb   :collections_json
      Time    :collections_updated_at

      Jsonb   :grants_json
      Time    :grants_updated_at

      Jsonb   :kpis_json
      Time    :kpis_updated_at

      Jsonb   :members_json
      Time    :members_updated_at

      Jsonb   :proposals_json
      Time    :proposals_updated_at

      Jsonb   :team_json
      Time    :team_updated_at

      # TODO: can be dropped
      Jsonb   :votes_json
      Time    :votes_updated_at
    end
  end
end
