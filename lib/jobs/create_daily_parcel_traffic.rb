module Jobs
  class CreateDailyParcelTraffic < Job
    sidekiq_options queue: 'processing'

    def perform(coordinates, date)
      Services::CreateDailyParcelTraffic.call(
        coordinates: coordinates,
        date: date
      )
    end
  end
end
