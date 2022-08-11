module Jobs
  class CreateScenes < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      coordinates = DATABASE_CONNECTION[
        "select distinct coordinates from data_points where date = '#{date}'"
      ].flat_map(&:values)

      coordinates.each do |parcel_coordinates|
        Services::CreateDailyParcelTraffic.call(
          coordinates: parcel_coordinates,
          date: date
        )
      end
    end
  end
end
