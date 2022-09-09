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
            parcels_visited: enrich_with_api_data(top_parcels_yesterday, user_data),
            time_spent: enrich_with_api_data(top_time_yesterday, user_data)
          },
          last_week: {
            parcels_visited: enrich_with_api_data(top_parcels_last_week, user_data),
            time_spent: enrich_with_api_data(top_time_last_week, user_data)
          },
          last_month: {
            parcels_visited: enrich_with_api_data(top_parcels_last_month, user_data),
            time_spent: enrich_with_api_data(top_time_last_month, user_data)
          },
          last_quarter: {
            parcels_visited: enrich_with_api_data(top_parcels_last_quarter, user_data),
            time_spent: enrich_with_api_data(top_time_last_quarter, user_data)
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

      def user_data
        @user_data ||= Services::FetchDclUserData.call(addresses: addresses)
      end

      def addresses
        @addresses ||= (
          top_parcels_yesterday +
          top_time_yesterday +
          top_parcels_last_week +
          top_time_last_week +
          top_parcels_last_month +
          top_time_last_month +
          top_parcels_last_quarter +
          top_time_last_quarter
        ).map { |row| row[:address] }.uniq
      end

      def enrich_with_api_data(data, user_data)
        data.each do |d|
          user = user_data.detect { |u| u[:address] == d[:address] }
          next unless user

          d[:avatar_url] = user[:avatar_url]
          d[:guest_user] = user[:guest_user]
          d[:name] = user[:name]
          d[:verified_user] = user[:verified_user]
        end

        # NOTE: might be useful for debugging
        # data.select { |d| d[:name].nil? }.each do |d|
        #   print "#{self.class.name}: can't find data for address #{d[:address]}\n"
        # end

        data
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
