module Adapters
  class Telegram
    URI = 'https://dcl-metrics-bot-server.herokuapp.com/telegram/internal'

    def self.send_message(text)
      # TODO: when stable
      # return unless ENV['RACK_ENV'] == 'production'
      unless ENV['RACK_ENV'] == 'production'
        text.prepend("---sent from #{ENV['RACK_ENV']} environment---\n\n")
      end

      new(text).send
    end

    def initialize(text)
      @msg = { text: text }.to_json
    end

    def send
      Faraday.post(URI, msg, "Content-Type" => "application/json")
    end

    private
    attr_reader :msg
  end
end
