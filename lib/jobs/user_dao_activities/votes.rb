module Jobs
  module UserDaoActivities
    class Votes < Job
      sidekiq_options queue: 'processing'

      def perform
        addresses = Models::DaoVote.distinct(:address).all

        addresses.each do |address|
          user_data = Models::DaoVote.where(address: address).order(:timestamp)

          Models::UserDaoActivity.update_or_create(address: address) do |uda|
            uda.votes_count = user_data.count
            uda.first_vote_cast_at = by_date.first.timestamp
            uda.latest_vote_cast_at = by_date.last.timestamp
          end
        end

        nil
      end
    end
  end
end
