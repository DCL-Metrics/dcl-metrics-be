module Jobs
  class CreateDailyParcelTraffic < Job
    sidekiq_options queue: 'processing'

    def perform(scene_cid, coordinates, date)
      Services::CreateDailyParcelTraffic.call(
        coordinates: coordinates,
        date: date,
        scene_cid: scene_cid
      )
    end
  end
end
