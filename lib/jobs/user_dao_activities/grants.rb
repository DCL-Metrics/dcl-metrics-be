module Jobs
  module UserDaoActivities
    class Grants < Job
      sidekiq_options queue: 'processing'

      def perform
        data = JSON.parse(Models::DaoGovernance.last.grants_json)

        data.group_by { |x| x['created_by'] }.each do |address, user_data|
          Models::UserDaoActivity.update_or_create(address: address) do |uda|
            uda.grants_authored_json = user_data.to_json
            uda.grants_authored_count = user_data.count
            # TODO: uda.grants_authored_total_requested
          end
        end

        data.group_by { |x| x['beneficiary'] }.each do |address, user_data|
          Models::UserDaoActivity.update_or_create(address: address) do |uda|
            uda.grants_beneficiary_json = user_data.to_json
            uda.grants_beneficiary_count = user_data.count
            # TODO: add grants_beneficiary_total_requested
            # TODO: add grants_beneficiary_total_enacted
            # select status enacted and sum amount
          end
        end

        nil
      end
    end
  end
end
