# primary_key :id
#
# String  :address,     null: false
# String  :proposal_id, null: false
# String  :title,       null: false
# String  :choice,      null: false
# Float   :vote_weight, null: false
# Integer :vp,          null: false
# Time    :timestamp,   null: false
#
# Time  :created_at, null: false
# Time  :updated_at, null: false
#
# add_index :dao_votes, :address
# add_index :dao_votes, [:address, :proposal_id, :timestamp], unique: true

module Models
  class DaoVote < Sequel::Model(FAT_BOY_DATABASE[:dao_votes])
  end
end
