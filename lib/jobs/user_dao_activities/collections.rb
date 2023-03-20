module Jobs
  module UserDaoActivities
    class Collections < Job
      sidekiq_options queue: 'processing'

      def perform
        data = JSON.parse(Models::DaoGovernance.last.collections_json)

        data.group_by { |x| x[:created_by] }.each do |address, user_data|
          UserDaoActivities.update_or_create(address: address) do |uda|
            uda.collections_json = user_data.to_json
            uda.collection_creator = user_data.any? { |x| x[:approved] }
          end
        end

        nil
      end
    end
  end
end
