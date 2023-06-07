module Adapters
  module Dcl
    class Worlds
      BASE_URL = 'https://worlds-content-server.decentraland.org/'
      STATUS_ENDPOINT = 'status'
      INDEX_ENDPOINT = 'index'
      DETAILS_ENDPOINT = 'live-data'

      def self.call
        new.call
      end

      def call
        content_server_response = Adapters::Base.get(BASE_URL + STATUS_ENDPOINT)
        return notify_failure(content_server_response) if content_server_response.failure?

        index_response = Adapters::Base.get(BASE_URL + INDEX_ENDPOINT)
        return notify_failure(index_response) if index_response.failure?

        details_response = Adapters::Base.get(BASE_URL + DETAILS_ENDPOINT)
        return notify_failure(details_response) if details_response.failure?

        status = content_server_response.success
        index = index_response.success['data']
        details = details_response.success['data']['perWorld']

        {
          world_count: status['content']['worldsCount'],
          total_user_count: status['comms']['users'].to_i,
          total_rooms: status['comms']['rooms'].to_i,
          data: consolidate_data(index, details)
        }
      end

      private

      def consolidate_data(index, details)
        index.map do |data|
          name = data['name']
          world_details = details.detect { |x| x['worldName'] == name }

          data.merge!({
            'user_count' => world_details.nil? ? 0 : world_details['users'].to_i
          })
        end
      end

      def notify_failure(response)
        Services::TelegramOperator.notify(
          level: :error,
          message: "#{self.class.name}: #{response.failure}"
        )
      end
    end
  end
end
