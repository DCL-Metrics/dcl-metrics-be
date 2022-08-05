module Adapters
  class Telegram
    URI = 'https://dcl-metrics-bot-server.herokuapp.com/telegram/internal'

    def self.send_message(level, message, payload)
      return unless ENV['RACK_ENV'] == 'production'

      new(level, message, payload).send
    end

    def initialize(level, message, payload)
      @msg = { level: level, message: message, payload: payload }.to_json
    end

    def send
      Faraday.post(URI, msg, "Content-Type" => "application/json")
    end

    private
    attr_reader :msg
  end
end
