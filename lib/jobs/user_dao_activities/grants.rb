module Jobs
  module UserDaoActivities
    class Grants < Job
      sidekiq_options queue: 'processing'

      def perform
        data = JSON.parse(Models::DaoGovernance.last.grants_json)

        data.group_by { |x| x['created_by'] }.each do |address, user_data|
          requested = user_data.sum { |x| x['amount'].to_i }
          enacted = user_data.
            select { |x| x['status'] == 'enacted' }.
            sum { |x| x['amount'].to_i }

          Models::UserDaoActivity.update_or_create(address: address) do |uda|
            uda.grants_authored_json = user_data.to_json
            uda.grants_authored_count = user_data.count
            uda.total_authored_grants_requested_usd = requested
            uda.total_authored_grants_enacted_usd = enacted
          end
        end

        data.group_by { |x| x['beneficiary'] }.each do |address, user_data|
          Models::UserDaoActivity.update_or_create(address: address) do |uda|
            requested = user_data.sum { |x| x['amount'].to_i }
            enacted = user_data.
              select { |x| x['status'] == 'enacted' }.
              sum { |x| x['amount'].to_i }

            uda.grants_beneficiary_json = user_data.to_json
            uda.grants_beneficiary_count = user_data.count
            uda.total_beneficiary_grants_requested_usd = requested
            uda.total_beneficiary_grants_enacted_usd = enacted
          end
        end

        nil
      end
    end
  end
end
