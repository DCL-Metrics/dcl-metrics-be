module Jobs
  module UserDaoActivities
    class Team < Job
      sidekiq_options queue: 'processing'

      def perform
        data = JSON.parse(Models::DaoGovernance.last.team_json)

        data.group_by { |x| x['address'] }.each do |address, user_data|
          Models::UserDaoActivity.update_or_create(address: address) do |uda|
            uda.active_dao_committee_member = user_data.any? { |x| x['active'] }
            uda.teams_json = user_data.to_json
          end
        end

        nil
      end
    end
  end
end
