module Serializers
  module Global
    class Parcels
      def self.serialize
        new.call
      end

      def call
        {
          daily: {
            logins:  calculate_daily(:logins),
            logouts: calculate_daily(:logouts),
            time_spent: calculate_daily(:time_spent),
            visitors: calculate_daily(:visitors)
          },
          top: {
            logins: calculate_top(:logins),
            logouts: calculate_top(:logouts),
            time_spent: calculate_top(:time_spent),
            visitors: calculate_top(:visitors)
          }
        }
      end

      private

      def calculate_daily(attribute)
        Models::DailyParcelStats.
          recent.
          exclude(attribute => nil).
          reverse_order(attribute).
          all.
          group_by { |stats| stats.date.to_s }.
          sort_by(&:first).
          to_h.
          transform_values! { |v| v.map(&:serialize) }
      end

      def calculate_top(attribute)
        result = {}

        Models::DailyParcelStats.
          recent.
          exclude(attribute => nil).
          all.
          group_by(&:address).
          each { |address, data| result[address] = data.sum(&attribute) }

        result.sort_by(&:last).reverse.to_h
      end
    end
  end
end
