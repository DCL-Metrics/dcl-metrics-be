module Serializers
  module Global
    class Users
      def self.serialize
        new.call
      end

      def call
        {
          daily: {
            parcels_visited: calculate_daily(:parcels_visited),
            time_spent: calculate_daily(:time_spent)
          },
          top: {
            parcels_visited: calculate_top(:parcels_visited),
            time_spent: calculate_top(:time_spent)
          }
        }
      end

      private

      def calculate_daily(attribute)
        Models::DailyUserStats.
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

        Models::DailyUserStats.
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
