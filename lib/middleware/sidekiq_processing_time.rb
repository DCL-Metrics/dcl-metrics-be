module Middleware
  class SidekiqProcessingTime
    def call(worker, job, queue)
      start_time = Time.now.utc
      yield
      end_time = Time.now.utc
      print "#{job['class']} completed in #{(end_time - start_time).round(2)}s\n"
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
