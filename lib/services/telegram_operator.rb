module Services
  class TelegramOperator
    LEVELS = %i[info error critical]

    def self.notify(level:, message:, payload: {})
      unless LEVELS.include?(level)
        raise ArgumentError, "[#{self.class.name}] Unknown level: #{level}"
      end

      new.notify(level, message, payload)
    end

    def notify(level, msg, payload)
      text = "#{level.upcase}:\n#{msg}\n\n"
      payload.each { |k,v| text += "#{k}: #{v}\n" }

      send_message(text)
    end

    private

    def send_message(text)
      Adapters::Telegram.send_message(text)
    end
  end
end
