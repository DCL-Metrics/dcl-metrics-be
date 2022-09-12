module Services
  class DailyDataAssessor
    def self.call(date)
      new(date).call
    end

    def initialize(date)
      @date = date
    end

    def call
      return static_result if date < Date.strptime('2022-09-11')

      Models::ApiResponseStatus.daily_failure_rate(date)
    end

    private
    attr_reader :date

    def static_result
      {
        '2022-07-16' => true,
        '2022-07-17' => true,
        '2022-07-18' => true,
        '2022-07-19' => true,
        '2022-07-20' => true,
        '2022-08-18' => true,
      }.fetch(date.to_s) { false }
    end
  end
end
