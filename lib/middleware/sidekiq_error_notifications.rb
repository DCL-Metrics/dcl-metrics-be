module Middleware
  class SidekiqErrorNotifications
    def call(worker, job, queue)
      begin
        yield
      rescue => error
        Services::TelegramOperator.notify(
          level: :error,
          message: error.inspect
        )

        # raising tells sidekiq to mark this job as failed
        # and move it to the retry queue
        raise
      end
    end
  end
end
