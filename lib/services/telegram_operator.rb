module Services
  class TelegramOperator
    LEVELS = %i[info error critical]

    def self.notify(level:, message:, payload: {})
      unless LEVELS.include?(level)
        raise ArgumentError, "[#{self.class.name}] Unknown level: #{level}"
      end

      Adapters::Telegram.send_message(level, message, payload)
    end
  end
end
