module Middleware
  class SidekiqErrorNotifications
    IGNORABLE_ERRORS = [
      Sequel::PoolTimeout,
      Sequel::ValidationFailed
    ]
    NON_RETRY_ERRORS = [Sequel::ValidationFailed]
    IGNORABLE_UNIQUE_CONSTRAINT = %w[
      Jobs::ProcessUser
      Jobs::FetchPeerStats
      Jobs::ProcessUserNfts
      Jobs::ProcessDaoActivity
    ]

    def call(worker, job, queue)
      begin
        yield
      rescue => e
        send_error_to_telegram(e, job)

        # raising tells sidekiq to mark this job as failed
        # and move it to the retry queue
        raise unless NON_RETRY_ERRORS.include?(e.class)
      end
    end

    def send_error_to_telegram(e, job)
      return if IGNORABLE_ERRORS.include?(e.class)
      return if IGNORABLE_UNIQUE_CONSTRAINT.include?(job['class']) &&
                e.class == Sequel::UniqueConstraintViolation

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
