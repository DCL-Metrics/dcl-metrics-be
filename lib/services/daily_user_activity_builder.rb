module Services
  class DailyUserActivityBuilder
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @addresses= DATABASE_CONNECTION[
        "select distinct address from data_points where date = '#{date}'"
      ].all.flat_map(&:values)
      @date = date
    end

    def call
      addresses.each do |address|
        next if address.nil?

        Jobs::ProcessDailyUserActivity.perform_async(address, date)
      end
    end

    private
    attr_reader :addresses, :date
  end
end
