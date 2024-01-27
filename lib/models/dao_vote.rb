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
# add_index :dao_votes, [:address, :proposal_id], unique: true

module Models
  class DaoVote < Sequel::Model(FAT_BOY_DATABASE[:dao_votes])
  end
end

# cartL = {
#   '0xed7461fd98758a84b76d6e941cbb92891443c36f' => 'robL',
#   '0x247e0896706BB09245549E476257A0A1129db418' => 'lordlike',
#   '0x2684a202a374d87bb321a744482b89bf6deaf8bd' => 'friskybumblebee',
#   '0xdce7d7f3ea933b214b1e73b47b079b631122596e' => 'metancy',
#   '0xed0e0cb94f60f72ec94bef848f5df4cbd365af1d' => 'injesterr',
#   '0x86edb92e217605dbecf606548e48daaf1b817da1' => 'metatrekkers',
#   '0xe161cc33f5b430be52aa69520d32cd3f39fa2be6' => 'unknown_whale'
# }
#
# addresses = cartL.keys.map(&:downcase)
# votes = Models::DaoVote.where(address: addresses)
#
# proposals = Models::DaoGovernance.last.proposals
# votes.all.group_by(&:proposal_id).each do |snapshot_id, data|
#   proposal = proposals.detect { |p| p['snapshot_id'].downcase == snapshot_id.downcase }
#   agree = data.map(&:choice).uniq.count == 1
#   puts "#{proposal&.dig("title")}: #{data.count}x #{agree ? 'agree' : 'disagree'}"
#   puts '+++++++++++++++++++++++++++++++++++++'
# end;nil
#
# agreement = votes.all.group_by(&:proposal_id).map do |snapshot_id, data|
#   # proposal = proposals.detect { |p| p['snapshot_id'].downcase == snapshot_id.downcase }
#   data.map(&:choice).uniq.count == 1
# end;nil


