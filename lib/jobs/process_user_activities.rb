module Jobs
  class ProcessUserActivities < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Services::DailyUserActivityBuilder.call(date: date)
    end
  end
end
