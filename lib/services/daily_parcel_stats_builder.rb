module Services
  class DailyParcelStatsBuilder
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @date = date
    end

    def call
      Models::DailyParcelStats.where(date: date).delete
      Jobs::ProcessDailyParcelStats.perform_async(date)
    end

    private
    attr_reader :date
  end
end
