module Jobs
  module UserDaoActivities
    class Proposals < Job
      sidekiq_options queue: 'processing'

      def perform
        data = JSON.parse(Models::DaoGovernance.last.proposals_json)

        data.group_by { |x| x['created_by'] }.each do |address, user_data|
          Models::UserDaoActivity.update_or_create(address: address) do |uda|
            uda.proposals_json = user_data.to_json
            uda.proposals_count = user_data.count
          end
        end

        nil
      end
    end
  end
end
