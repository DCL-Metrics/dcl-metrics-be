module Adapters
  module Dcl
    class Worlds
      CONTENT_SERVER_URL = "https://worlds-content-server.decentraland.org/status"

      def self.call
        new.call
      end

      def call
        content_server_response = Adapters::Base.get(CONTENT_SERVER_URL)
        return notify_failure(content_server_response) if content_server_response.failure?

        p content_server_response

        data = content_server_response.success

        {
          world_count: data['content']['worldsCount'],
          total_user_count: data['comms']['users'].to_i,
          total_rooms: data['comms']['rooms'].to_i
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
