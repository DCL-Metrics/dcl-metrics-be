module Serializers
  module Global
    class Users
      def self.serialize
        new.call
      end

      def call
        @top_parcels_yesterday = calculate_top(:parcels_visited, :yesterday)
        @top_scenes_yesterday = calculate_top(:scenes_visited, :yesterday)
        @top_time_yesterday = calculate_top(:time_spent, :yesterday)

        @top_parcels_last_week = calculate_top(:parcels_visited, :last_week)
        @top_scenes_last_week = calculate_top(:scenes_visited, :last_week)
        @top_time_last_week = calculate_top(:time_spent, :last_week)

        @top_parcels_last_month = calculate_top(:parcels_visited, :last_month)
        @top_scenes_last_month = calculate_top(:scenes_visited, :last_month)
        @top_time_last_month = calculate_top(:time_spent, :last_month)

        @top_parcels_last_quarter = calculate_top(:parcels_visited, :last_quarter)
        @top_scenes_last_quarter = calculate_top(:scenes_visited, :last_quarter)
        @top_time_last_quarter = calculate_top(:time_spent, :last_quarter)

        {
          yesterday: {
            parcels_visited: enrich_user_data(@top_parcels_yesterday),
            scenes_visited: enrich_user_data(@top_scenes_yesterday),
            time_spent: enrich_user_data(@top_time_yesterday)
          },
          last_week: {
            parcels_visited: enrich_user_data(@top_parcels_last_week),
            scenes_visited: enrich_user_data(@top_scenes_last_week),
            time_spent: enrich_user_data(@top_time_last_week)
          },
          last_month: {
            parcels_visited: enrich_user_data(@top_parcels_last_month),
            scenes_visited: enrich_user_data(@top_scenes_last_month),
            time_spent: enrich_user_data(@top_time_last_month)
          },
          last_quarter: {
            parcels_visited: enrich_user_data(@top_parcels_last_quarter),
            scenes_visited: enrich_user_data(@top_scenes_last_quarter),
            time_spent: enrich_user_data(@top_time_last_quarter)
          }
        }
      end

      private

      def calculate_top(attribute, period)
        date = calculate_start_of_period(period)

        result = DATABASE_CONNECTION[
          "select address, sum(#{attribute}) as #{attribute}
          from daily_user_stats
          where date >= '#{date}'
          and #{attribute} is not null
          group by address
          order by 2"
        ]

        wrap_data(result, attribute)
      end

      def wrap_data(data, attribute)
        data.
        all.
        last(10).
        reverse
      end

      def enrich_user_data(users)
        Services::EnrichUserData.call(users: users)
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
