module Services
  class DailyStatsBuilder
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @date = date
    end

    def call
      Jobs::ProcessDailyStats.perform_async(date)
    end

    private
    attr_reader :date
  end
end
