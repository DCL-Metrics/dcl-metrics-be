module Services
  class DailyUserActivityBuilder
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @date = date
    end

    def call
      Models::DataPoint.where(date: date).select(:address).distinct.lazy.each_slice(500) do |batch|
        batch.each do |data_point|
          address = data_point.address
          next if address.nil?

          Jobs::ProcessDailyUserActivity.perform_async(address, date)
        end
      end
    end

    private
    attr_reader :date
  end
end
