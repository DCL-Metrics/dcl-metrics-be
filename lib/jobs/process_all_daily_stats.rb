module Jobs
  class ProcessAllDailyStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Services::DailyStatsBuilder.call(date: date)
      Services::DailyUserStatsBuilder.call(date: date)
      Services::DailyParcelStatsBuilder.call(date: date)
    end
  end
end
