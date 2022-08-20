module Jobs
  class ProcessSnapshots < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Services::ProcessSnapshots.call(date: date)
    end
  end
end
