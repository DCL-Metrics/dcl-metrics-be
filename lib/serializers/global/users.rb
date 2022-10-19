module Serializers
  module Global
    class Users
      def self.serialize
        new.call
      end

      def call
        @top_parcels_yesterday = calculate_top(:parcels_visited, :yesterday)
        @top_time_yesterday = calculate_top(:time_spent, :yesterday)

        @top_parcels_last_week = calculate_top(:parcels_visited, :last_week)
        @top_time_last_week = calculate_top(:time_spent, :last_week)

        @top_parcels_last_month = calculate_top(:parcels_visited, :last_month)
        @top_time_last_month = calculate_top(:time_spent, :last_month)

        @top_parcels_last_quarter = calculate_top(:parcels_visited, :last_quarter)
        @top_time_last_quarter = calculate_top(:time_spent, :last_quarter)

        {
          yesterday: {
            parcels_visited: enrich_user_data(top_parcels_yesterday),
            time_spent: enrich_user_data(top_time_yesterday)
          },
          last_week: {
            parcels_visited: enrich_user_data(top_parcels_last_week),
            time_spent: enrich_user_data(top_time_last_week)
          },
          last_month: {
            parcels_visited: enrich_user_data(top_parcels_last_month),
            time_spent: enrich_user_data(top_time_last_month)
          },
          last_quarter: {
            parcels_visited: enrich_user_data(top_parcels_last_quarter),
            time_spent: enrich_user_data(top_time_last_quarter)
          }
        }
      end

      private
      attr_reader :top_parcels_yesterday,
                  :top_time_yesterday,
                  :top_parcels_last_week,
                  :top_time_last_week,
                  :top_parcels_last_month,
                  :top_time_last_month,
                  :top_parcels_last_quarter,
                  :top_time_last_quarter

      def calculate_top(attribute, period)
        result = []

          data[period].
            exclude(attribute => nil).
            all.
            group_by { |row| row[:address] }.
            each do |address, data|
              result.push({
                address: address,
                attribute => data.sum { |row| row[attribute] },
                avatar_url: nil,
                guest_user: nil,
                name: nil,
                verified_user: nil
              })
            end

        result.sort_by { |row| row[attribute] }.last(10).reverse
      end

      def enrich_user_data(users)
        Services::EnrichUserData.call(data: users)
      end

      def data
        {
          yesterday: Models::DailyUserStats.yesterday,
          last_week: Models::DailyUserStats.last_week,
          last_month: Models::DailyUserStats.last_month,
          last_quarter: Models::DailyUserStats.last_quarter
        }
      end
    end
  end
end
