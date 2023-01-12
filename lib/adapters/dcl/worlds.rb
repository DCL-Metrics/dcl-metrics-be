module Adapters
  module Dcl
    class Worlds
      CONTENT_SERVER_URL = "https://worlds-content-server.decentraland.org/status"
      ROOMS_SERVICE_URL  = "https://ws-room-service.decentraland.org/status"

      def self.call
        new.call
      end

      def call
        content_server_response = Adapters::Base.get(CONTENT_SERVER_URL)
        rooms_service_response  = Adapters::Base.get(CONTENT_SERVER_URL)

        return notify_failure(content_server_response) if content_server_response.failure?
        return notify_failure(rooms_service_response) if rooms_service_response.failure?

        content_data = content_server_response.success
        rooms_data = rooms_service_response.success

        {
          worlds_count: content_data['worldsCount'],
          total_user_count: rooms_data['users'].to_i,
          total_rooms: rooms_data['rooms'].to_i
        }
      end

      private

      def notify_failure(response)
        Services::TelegramOperator.notify(
          level: :error,
          message: "#{self.class.name}: #{response.failure}"
        )
      end
    end
  end
end
