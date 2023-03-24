print "updates index on dao_votes table\n"

Sequel.migration do
  change do
    alter_table(:dao_votes) do
      drop_index [:address, :proposal_id]
      add_index [:address, :proposal_id, :timestamp], unique: true
    end
  end
end
