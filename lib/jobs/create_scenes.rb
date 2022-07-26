module Jobs
  class ProcessAllDailyStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Services::CreateScenesOnDate.call(date: date)
    end
  end
end
