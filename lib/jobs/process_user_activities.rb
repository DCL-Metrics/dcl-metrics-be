module Jobs
  class ProcessUserActivities < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Models::UserActivity.where(date: date).delete
      Services::DailyUserActivityBuilder.call(date: date)
    end
  end
end
