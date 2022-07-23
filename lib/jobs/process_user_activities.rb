module Jobs
  class ProcessUserActivities < Job
    def perform(date)
      Services::DailyUserActivityBuilder.call(date: date)
    end
  end
end
