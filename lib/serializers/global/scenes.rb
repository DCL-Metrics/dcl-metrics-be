module Serializers
  module Global
    class Scenes
      # TODO: write a test after there is 7 days of data
      def self.serialize
        new.call
      end

      def call
        {
          yesterday: {
            logins: calculate_data(:top, :total_logins, :yesterday),
            logouts: calculate_data(:top, :total_logouts, :yesterday),
            time_spent: calculate_data(:max, :avg_time_spent, :yesterday),
            time_spent_afk: calculate_data(:max, :avg_time_spent_afk, :yesterday),
            visitors: calculate_data(:top, :unique_addresses, :yesterday)
          },
          last_week: {
            logins: calculate_data(:top, :total_logins, :last_week),
            logouts: calculate_data(:top, :total_logouts, :last_week),
            time_spent: calculate_data(:max, :avg_time_spent, :last_week),
            time_spent_afk: calculate_data(:max, :avg_time_spent_afk, :last_week),
            visitors: calculate_data(:top, :unique_addresses, :last_week)
          },
          last_month: {
            logins: calculate_data(:top, :total_logins, :last_month),
            logouts: calculate_data(:top, :total_logouts, :last_month),
            time_spent: calculate_data(:max, :avg_time_spent, :last_month),
            time_spent_afk: calculate_data(:max, :avg_time_spent_afk, :last_month),
            visitors: calculate_data(:top, :unique_addresses, :last_month)
          },
          last_quarter: {
            logins: calculate_data(:top, :total_logins, :last_quarter),
            logouts: calculate_data(:top, :total_logouts, :last_quarter),
            time_spent: calculate_data(:max, :avg_time_spent, :last_quarter),
            time_spent_afk: calculate_data(:max, :avg_time_spent_afk, :last_quarter),
            visitors: calculate_data(:top, :unique_addresses, :last_quarter)
          }
        }
      end

      private

      # sum + group by
      def calculate_data(type, attribute, period)
        operation = operation_mapping[type]
        date = calculate_start_of_period(period)

        result = DATABASE_CONNECTION[
          "select name,
                  coordinates,
                  scene_disambiguation_uuid as uuid,
                  #{operation}(#{attribute}) as #{attribute}
          from daily_scene_stats
          where date >= '#{date}'
          and #{attribute} is not null
          and #{attribute} != 0
          group by name, coordinates, uuid
          order by 4"
        ]

        wrap_data(result, attribute)
      end

      def wrap_data(data, attribute)
        data.
        all.
        last(5).
        reverse.
        map { |hash| [hash[:name], build_output_hash(attribute, hash)] }.
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

      def build_output_hash(attribute, data)
        {
          attribute.to_sym => data[attribute],
          uuid: data[:uuid],
          map_url: map_url(data[:coordinates])
        }
      end

      def map_url(coordinates)
        center = coordinates.split(';').first

        "https://api.decentraland.org/v2/map.png?center=#{center}&selected=#{coordinates}"
      end
    end
  end
end
