module Serializers
  module Global
    class Parcels
      def self.serialize
        new.call
      end

      def call
        {
          yesterday: {
            logins: calculate_data(:top, :logins, :yesterday),
            logouts: calculate_data(:top, :logouts, :yesterday),
            time_spent: calculate_data(:max, :avg_time_spent, :yesterday),
            time_spent_afk: calculate_data(:max, :avg_time_spent_afk, :yesterday),
            visitors: calculate_data(:top, :unique_visitors, :yesterday),
            max_concurrent_users: calculate_data(:max, :max_concurrent_users, :yesterday)
          },
          last_week: {
            logins: calculate_data(:top, :logins, :last_week),
            logouts: calculate_data(:top, :logouts, :last_week),
            time_spent: calculate_data(:max, :avg_time_spent, :last_week),
            time_spent_afk: calculate_data(:max, :avg_time_spent_afk, :last_week),
            visitors: calculate_data(:top, :unique_visitors, :last_week),
            max_concurrent_users: calculate_data(:max, :max_concurrent_users, :last_week)
          },
          last_month: {
            logins: calculate_data(:top, :logins, :last_month),
            logouts: calculate_data(:top, :logouts, :last_month),
            time_spent: calculate_data(:max, :avg_time_spent, :last_month),
            time_spent_afk: calculate_data(:max, :avg_time_spent_afk, :last_month),
            visitors: calculate_data(:top, :unique_visitors, :last_month),
            max_concurrent_users: calculate_data(:max, :max_concurrent_users, :last_month)
          },
          last_quarter: {
            logins: calculate_data(:top, :logins, :last_quarter),
            logouts: calculate_data(:top, :logouts, :last_quarter),
            time_spent: calculate_data(:max, :avg_time_spent, :last_quarter),
            time_spent_afk: calculate_data(:max, :avg_time_spent_afk, :last_quarter),
            visitors: calculate_data(:top, :unique_visitors, :last_quarter),
            max_concurrent_users: calculate_data(:max, :max_concurrent_users, :last_quarter)
          }
        }
      end

      private

      # sum + group by
      def calculate_data(type, attribute, period)
        operation = operation_mapping[type]
        date = calculate_start_of_period(period)

        result = FAT_BOY_DATABASE[
          "select coordinates, #{operation}(#{attribute}) as #{attribute}
          from daily_parcel_stats
          where date >= '#{date}'
          and #{attribute} is not null
          group by coordinates
          order by 2"
        ]

        wrap_data(result, attribute)
      end

      def wrap_data(data, attribute)
        data.
        all.
        last(5).
        reverse.
        map { |hash| [hash[:coordinates], hash[attribute]] }.
        to_h
      end

      def operation_mapping
        {
          max: :max,
          top: :sum
        }
      end

      def calculate_start_of_period(period)
        Date.today - period_mapping[period]
      end

      def period_mapping
        {
          yesterday: 1,
          last_week: 7,
          last_month: 30,
          last_quarter: 90
        }
      end
    end
  end
end
