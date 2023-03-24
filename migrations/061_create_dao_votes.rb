print "creating dao_votes table\n"

Sequel.migration do
  change do
    create_table(:dao_votes) do
      primary_key :id

      String  :address,     null: false
      String  :proposal_id, null: false
      String  :title,       null: false
      String  :choice,      null: false
      Float   :vote_weight, null: false
      Integer :vp,          null: false
      Time    :timestamp,   null: false

      Time  :created_at, null: false
      Time  :updated_at, null: false
    end

    add_index :dao_votes, :address
    add_index :dao_votes, [:address, :proposal_id], unique: true
  end
end
