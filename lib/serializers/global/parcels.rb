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
            time_spent: calculate_daily(:avg_time_spent),
            visitors: calculate_daily(:unique_visitors)
          },
          top: {
            logins: calculate_top(:logins),
            logouts: calculate_top(:logouts),
            time_spent: calculate_top(:avg_time_spent),
            visitors: calculate_top(:unique_visitors)
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
          group_by(&:coordinates).
          each { |c, data| result[c] = sum_parcel_attributes(data) }

        result.sort_by { |k,v| v[attribute] }.reverse.to_h
      end

      def sum_parcel_attributes(data)
        attributes = %i[avg_time_spent avg_time_spent_afk unique_visitors logins logouts]
        result = {}

        attributes.each { |a| result[a] = data.sum { |d| d[a].to_i } }
        result
      end
    end
  end
end
