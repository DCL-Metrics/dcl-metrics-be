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
          group_by { |s| [s.name, s.coordinates] }.
          each do |grouping, data|
            result[grouping.first] = build_values(data, attribute, grouping.last)
          end

        result.sort_by { |name, values| values[attribute] }.last(5).reverse.to_h
      end

      def build_values(data, attribute, coordinates)
        {
          attribute => data.sum { |d| d[attribute].to_i },
          map_url: build_map_url(coordinates)
        }
      end

      def build_map_url(coordinates)
        center = coordinates.split(';').first
        selected = coordinates

        "https://api.decentraland.org/v2/map.png?center=#{center}&selected=#{selected}"
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
