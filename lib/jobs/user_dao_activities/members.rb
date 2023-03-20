module Jobs
  module UserDaoActivities
    class Members < Job
      sidekiq_options queue: 'processing'

      def perform
        data = JSON.parse(Models::DaoGovernance.last.members_json)

        data.group_by { |x| x[:address] }.each do |address, user_data|
          UserDaoActivities.update_or_create(address: address) do |uda|
            uda.total_vp = user_data[:vp]
            uda.delegated_vp = user_data[:delegated_vp]
            uda.degators = user_data[:delegators].join(';')
            uda.delegate = user_data[:delegate]
          end
        end

        nil
      end
    end
  end
end
