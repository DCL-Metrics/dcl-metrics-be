module Adapters
  module AtlasCorp
    class DailyUsers
      URL = 'https://dao-data.atlascorp.io/daily-active-users'

      def self.call(date:)
        new(date).call
      end


      def initialize(date)
        @date = "#{date}T00:00:00Z" # required format
      end

      def call
        response = Adapters::Base.get(URL, { date: date })
        return {} if response.failure?

        data = response.success.first

        {
          count: data['count'],
          addresses: data['unique-users']
        }
      end

      private
      attr_reader :date
    end
  end
end
