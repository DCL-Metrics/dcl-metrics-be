module Middleware
  class SidekiqErrorNotifications
    IGNORABLE_ERRORS = [Sequel::PoolTimeout]
    def call(worker, job, queue)
      begin
        yield
      rescue => e
        send_error_to_telegram(e, job)

        # raising tells sidekiq to mark this job as failed
        # and move it to the retry queue
        raise
      end
    end

    def send_error_to_telegram(e, job)
      return if IGNORABLE_ERRORS.include?(e.class)

      Services::TelegramOperator.notify(
        level: :error,
        message: 'Error in sidekiq job',
        payload: job.merge({
          error_class: e.class,
          error_msg: e.message,
        })
      )
    end
  end
end
