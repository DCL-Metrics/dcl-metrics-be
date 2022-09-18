module Jobs
  class ProcessAllDailyStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Services::DailyStatsBuilder.call(date: date)
      Services::DailyUserStatsBuilder.call(date: date)
      Services::DailyParcelStatsBuilder.call(date: date)

      # perform this after two minutes
      # cause daily stats need to be fully finished
      # before the daily scene stats can processed
      Jobs::PreprocessDailySceneStats.perform_in(120, date)
    end
  end
end
