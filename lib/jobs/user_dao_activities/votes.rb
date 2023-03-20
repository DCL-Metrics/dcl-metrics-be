module Jobs
  module UserDaoActivities
    class Votes < Job
      sidekiq_options queue: 'processing'

      def perform
        data = JSON.parse(Models::DaoGovernance.last.votes_json)

        data.group_by(:address).each do |address, user_data|
          by_date = user_data.sort_by { |x| x[:created_at] }

          UserDaoActivities.update_or_create(address: address) do |uda|
            uda.votes_json = by_date.to_json
            uda.votes_count = user_data.count
            uda.first_vote_cast_at = by_date.first.created_at
            uda.latest_vote_cast_at = by_date.last.created_at
          end
        end

        nil
      end
    end
  end
end
