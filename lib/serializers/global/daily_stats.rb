module Serializers
  module Global
    class DailyStats
      def self.serialize
        new.call
      end

      def call
        Models::DailyStats.last_quarter.order(:date).all.inject({}) do |result, row|
          data = row.serialize.merge(degraded: degraded?(row.date))
          result[row.date.to_s] = data
          result
        end
      end

      private

      def degraded?(date)
        Services::DailyDataAssessor.call(date)
      end
    end
  end
end
