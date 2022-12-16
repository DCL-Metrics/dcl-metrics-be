module Jobs
  class ProcessDailyStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      unique_users = FAT_BOY_DATABASE[
        "select distinct address from data_points where date = '#{date}'"
      ].count

      parcels_visited = FAT_BOY_DATABASE[
        "select distinct coordinates from data_points where date = '#{date}'"
      ].count

      scene_cids_on_date = FAT_BOY_DATABASE[
        "select distinct scene_cid from data_points where date = '#{date}'"
      ].all.flat_map(&:values).compact

      scenes_visited = Models::Scene.collect(scene_cids_on_date).count

      Models::DailyStats.create(
        date: date,
        unique_users: unique_users,
        total_active_parcels: parcels_visited,
        total_active_scenes: scenes_visited
      )

      nil
    end
  end
end
