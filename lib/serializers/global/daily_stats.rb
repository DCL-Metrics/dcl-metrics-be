module Serializers
  module Global
    class DailyStats
      def self.serialize(after_date = nil)
        new(after_date).call
      end

      def initialize(after_date = nil)
        @after_date = after_date
      end

      def call
        base = Models::DailyStats.order(:date)
        base = after_date.nil? ? base.all : base.where { date > after_date }

        base.inject({}) do |result, row|
          data = row.serialize.merge(degraded: degraded?(row.date))
          result[row.date.to_s] = data
          result
        end
      end

      private
      attr_reader :after_date

      def degraded?(date)
        Services::DailyDataAssessor.call(date)
      end
    end
  end
end
