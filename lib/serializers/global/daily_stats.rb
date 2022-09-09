module Serializers
  module Global
    class DailyStats
      def self.serialize
        new.call
      end

      def call
        Models::DailyStats.last_quarter.order(:date).all.inject({}) do |result, row|
          result[row.date.to_s] = row.serialize
          result
        end
      end
    end
  end
end
