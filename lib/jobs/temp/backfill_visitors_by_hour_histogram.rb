module Jobs
  module Temp
    class BackfillVisitorsByHourHistogram < Job
      sidekiq_options queue: 'processing'

      def perform(date)
        Models::DailySceneStats.where(date: date).each do |stat|
          Jobs::Temp::BackfillVisitorsByHourHistogramForModel.perform_async(stat.id)
        end

        nil
      end
    end
  end
end
