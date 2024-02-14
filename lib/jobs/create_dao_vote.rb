module Jobs
  class CreateDaoVote < Job
    sidekiq_options queue: 'processing'

    def perform(address, proposal_id, title, choice, vote_weight, vp, timestamp)
      query = {
        address: address,
        proposal_id: proposal_id,
        timestamp: timestamp
      }

      Models::DaoVote.find_or_create(query) do |vote|
        vote.title = title
        vote.choice = choice
        vote.vote_weight = vote_weight
        vote.vp = vp
      end
    end
  end
end
