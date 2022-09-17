module Middleware
  class SidekiqErrorNotifications
    def call(worker, job, queue)
      begin
        yield
      rescue => e
        Services::TelegramOperator.notify(
          level: :error,
          message: 'Error in sidekiq job',
          payload: {
            error_class: error.class,
            error_msg: error.message,
            job: job,
            queue: queue,
            worker: worker
          }
        )

        # raising tells sidekiq to mark this job as failed
        # and move it to the retry queue
        raise
      end
    end
  end
end
