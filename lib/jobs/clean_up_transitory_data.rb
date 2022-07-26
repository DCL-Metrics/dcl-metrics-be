module Jobs
  class CleanUpTransitoryData < Job
    sidekiq_options queue: 'low'

    def perform
      # NOTE: don't remove data points for now. let's see
      # DATABASE_CONNECTION[:data_points].truncate
      DATABASE_CONNECTION[:user_activities].truncate

      nil
    end
  end
end
