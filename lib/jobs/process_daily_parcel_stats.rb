module Jobs
  class ProcessDailyParcelStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      coordinates = DATABASE_CONNECTION[
        "select distinct(coordinates) from parcel_traffic where date = '#{date}'"
      ].flat_map(&:values)

      coordinates.each { |c| Jobs::ProcessParcelStats.perform_async(date, c) }

      nil
    end
  end
end
