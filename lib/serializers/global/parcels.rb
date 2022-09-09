module Serializers
  module Global
    class Parcels
      def self.serialize
        new.call
      end

      def call
        {
          yesterday: {
            logins: calculate_top(:logins, :yesterday),
            logouts: calculate_top(:logouts, :yesterday),
            time_spent: calculate_top(:avg_time_spent, :yesterday),
            time_spent_afk: calculate_top(:avg_time_spent_afk, :yesterday),
            visitors: calculate_top(:unique_visitors, :yesterday)
          },
          last_week: {
            logins: calculate_top(:logins, :last_week),
            logouts: calculate_top(:logouts, :last_week),
            time_spent: calculate_top(:avg_time_spent, :last_week),
            time_spent_afk: calculate_top(:avg_time_spent_afk, :last_week),
            visitors: calculate_top(:unique_visitors, :last_week)
          },
          last_month: {
            logins: calculate_top(:logins, :last_month),
            logouts: calculate_top(:logouts, :last_month),
            time_spent: calculate_top(:avg_time_spent, :last_month),
            time_spent_afk: calculate_top(:avg_time_spent_afk, :last_month),
            visitors: calculate_top(:unique_visitors, :last_month)
          },
          last_quarter: {
            logins: calculate_top(:logins, :last_quarter),
            logouts: calculate_top(:logouts, :last_quarter),
            time_spent: calculate_top(:avg_time_spent, :last_quarter),
            time_spent_afk: calculate_top(:avg_time_spent_afk, :last_quarter),
            visitors: calculate_top(:unique_visitors, :last_quarter)
          }
        }
      end

      private

      def calculate_top(attribute, period)
        result = {}

        data[period].
          exclude(attribute => nil).
          all.
          group_by(&:coordinates).
          each { |c, data| result[c] = data.sum { |d| d[attribute].to_i } }

        result.sort_by { |k,v| v }.last(5).reverse.to_h
      end

      def data
        {
          yesterday: Models::DailyParcelStats.yesterday,
          last_week: Models::DailyParcelStats.last_week,
          last_month: Models::DailyParcelStats.last_month,
          last_quarter: Models::DailyParcelStats.last_quarter
        }
      end
    end
  end
end
