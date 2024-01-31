module Jobs
  class CreateDaoVote < Job
    sidekiq_options queue: 'processing'

    def perform(vote)
      query = {
        address: vote[:address],
        proposal_id: vote[:proposal_id],
        timestamp: vote[:timestamp]
      }

      Models::DaoVote.find_or_create(query) do |vote|
        vote.title = vote[:title]
        vote.choice = vote[:choice]
        vote.vote_weight = vote[:vote_weight]
        vote.vp = vote[:vp]
      end
    end
  end
end
