module Jobs
  class ProcessDailyParcelTraffic < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      coordinates = FAT_BOY_DATABASE[
        "select distinct coordinates from data_points where date = '#{date}'"
      ].flat_map(&:values)

      coordinates.each do |c|
        Jobs::CreateDailyParcelTraffic.perform_async(c, date)
      end
    end
  end
end
