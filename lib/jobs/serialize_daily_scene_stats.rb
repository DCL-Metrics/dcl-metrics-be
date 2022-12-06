module Jobs
  class SerializeDailySceneStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Models::SerializedDailySceneStats.where(date: date).delete

      Models::DailySceneStats.
        yesterday.
        select(:id).
        flat_map { |stat| stat.values[:id] }.
        each { |id| Jobs::SerializeDailySceneStat.perform_async(id) }
    end
  end
end
