module Jobs
  class ProcessDaoActivities < Job
    sidekiq_options queue: 'processing'

    SHEETS_TO_PULL = %w[
      KPIs
      Collections
      Projects
      Members
      Proposals
      Team
      Votes
    ]

    # NOTE: each of these jobs should pull the data for the given sheet.
    # if it's changed compared to the associated DaoGovernance DB column,
    # then overwrite that column and run the job to update user_dao_activities
    # which rely on that data, otherwise do nothing.
    def perform
      SHEETS_TO_PULL.each do |sheet|
        Jobs::ProcessDaoActivity.perform_async(sheet)
      end
    end
  end
end
