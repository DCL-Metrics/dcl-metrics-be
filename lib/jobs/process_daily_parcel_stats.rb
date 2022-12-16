module Jobs
  class ProcessDailyParcelStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      coordinates = FAT_BOY_DATABASE[
        "select distinct(coordinates) from data_points where date = '#{date}'"
      ].flat_map(&:values)

      coordinates.each { |c| Jobs::ProcessParcelStats.perform_async(date, c) }

      nil
    end
  end
end
