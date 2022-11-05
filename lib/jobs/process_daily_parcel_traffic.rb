module Jobs
  class ProcessDailyParcelTraffic < Job
    sidekiq_options queue: 'processing'

    # NOTE: this is a small but very important point:
    # we want to select the distinct combination of scene_cids and coordinates
    # by date so that we are compiling stats in a way that can reasonably be
    # counted on a scene by scene basis.
    #
    # if we just select scene_cids, we're creating scene based stats, which is
    # not wrong but it's too broad because we lose all stats for individual
    # parcels that have no scene on them (maybe there's a group of people
    # hanging out on a weedy lot..? maybe not important, but those are valid
    # stats)
    #
    # if we just select coordinates, it's nearly impossible to create
    # intelligible scene-based stats because parcel traffic for a given day gets
    # all merged together even though the same parcel might host several scenes
    # during that time
    def perform(date)
      Models::ParcelTraffic.where(date: date).delete

      parcels_by_scene_cid = FAT_BOY_DATABASE[
        "select scene_cid, coordinates
        from data_points
        where date = '#{date}'
        group by scene_cid, coordinates
        "
      ].map(&:values)

      parcels_by_scene_cid.each do |scene_cid, coordinates|
        Jobs::CreateDailyParcelTraffic.perform_async(scene_cid, coordinates, date)
      end
    end
  end
end
