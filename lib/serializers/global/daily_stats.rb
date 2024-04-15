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
        query = "select * from daily_stats"
        query += " where date > '#{after_date}'" unless after_date.nil?
        query += " order by date"

        data = DATABASE_CONNECTION[query].all

        data.inject({}) do |result, row|
          data = serialize(row)
          result[row[:date].to_s] = data
          result
        end
      end

      private
      attr_reader :after_date

      def serialize(row)
        {
          active_parcels: row[:total_active_parcels],
          active_scenes: row[:total_active_scenes],
          degraded: Services::DailyDataAssessor.call(row[:date]),
          users: {
            guest_users: row[:guest_users],
            named_users: row[:named_users],
            new_users: row[:new_users],
            unique_users: row[:unique_users]
          }
        }
      end
    end
  end
end
