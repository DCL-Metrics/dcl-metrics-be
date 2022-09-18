module Jobs
  class PreprocessDailySceneStats < Job
    sidekiq_options queue: 'processing'

    DailyStatsNotReady = Class.new(RuntimeError)

    def perform(date)
      begin
        # NOTE: daily stats might not be ready yet by the time this is called
        daily_stats = Models::DailyStats.find(date: date)
        raise DailyStatsNotReady if daily_stats.nil?

        Services::DailySceneStatsBuilder.call(
          date: date,
          unique_users: daily_stats.unique_users
        )
      rescue DailyStatsNotReady
        Services::TelegramOperator.notify(
          level: :info,
          message: "#{self.class.name}: Retrying job, daily stats not yet processed"
        )

        perform_in(120, date)
      end
    end
  end
end
