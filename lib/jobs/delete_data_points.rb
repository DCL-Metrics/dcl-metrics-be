module Jobs
  class DeleteDataPoints < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Models::DataPoint.where(date: date).delete
    end
  end
end
