module Serializers
  module Global
    class Scenes
      def self.serialize
        new.call
      end

      def call
        {
          yesterday: {
            logins: calculate_top(:total_logins, :yesterday),
            logouts: calculate_top(:total_logouts, :yesterday),
            time_spent: calculate_top(:avg_time_spent, :yesterday),
            time_spent_afk: calculate_top(:avg_time_spent_afk, :yesterday),
            visitors: calculate_top(:unique_addresses, :yesterday)
          },
          last_week: {
            logins: calculate_top(:total_logins, :last_week),
            logouts: calculate_top(:total_logouts, :last_week),
            time_spent: calculate_top(:avg_time_spent, :last_week),
            time_spent_afk: calculate_top(:avg_time_spent_afk, :last_week),
            visitors: calculate_top(:unique_addresses, :last_week)
          },
          last_month: {
            logins: calculate_top(:total_logins, :last_month),
            logouts: calculate_top(:total_logouts, :last_month),
            time_spent: calculate_top(:avg_time_spent, :last_month),
            time_spent_afk: calculate_top(:avg_time_spent_afk, :last_month),
            visitors: calculate_top(:unique_addresses, :last_month)
          },
          last_quarter: {
            logins: calculate_top(:total_logins, :last_quarter),
            logouts: calculate_top(:total_logouts, :last_quarter),
            time_spent: calculate_top(:avg_time_spent, :last_quarter),
            time_spent_afk: calculate_top(:avg_time_spent_afk, :last_quarter),
            visitors: calculate_top(:unique_addresses, :last_quarter)
          }
        }
      end

      private

      def calculate_top(attribute, period)
        result = {}

        data[period].
          exclude(attribute => nil).
          exclude(attribute => 0).
          all.
          group_by(&:name).
          each { |name, data| result[name] = data.sum { |d| d[attribute].to_i } }

        result.sort_by(&:last).last(5).reverse.to_h
      end

      def data
        {
          yesterday: Models::DailySceneStats.yesterday,
          last_week: Models::DailySceneStats.last_week,
          last_month: Models::DailySceneStats.last_month,
          last_quarter: Models::DailySceneStats.last_quarter
        }
      end
    end
  end
end
