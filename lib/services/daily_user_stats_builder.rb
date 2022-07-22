module Services
  class DailyUserStatsBuilder
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @date = date
    end

    def call
      Models::DailyUserStats.where(date: date).delete
      Jobs::ProcessDailyUserStats.perform_async(date)
    end

    private
    attr_reader :date
  end
end
