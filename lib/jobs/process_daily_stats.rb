module Jobs
  class ProcessDailyStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      addresses = FAT_BOY_DATABASE[
        "select distinct address from data_points where date = '#{date}'"
      ].flat_map(&:values).compact

      users = Models::User.where(address: addresses)
      guest_users = users.where(guest: true).count
      new_users = users.where(first_seen: date).count
      named_users = Models::UserNfts.where(address: addresses, owns_dclens: true).count

      parcels_visited = FAT_BOY_DATABASE[
        "select distinct coordinates from data_points where date = '#{date}'"
      ].count

      scene_cids_on_date = FAT_BOY_DATABASE[
        "select distinct scene_cid from data_points where date = '#{date}'"
      ].all.flat_map(&:values).compact

      scenes_visited = Models::Scene.collect(scene_cids_on_date).count

      Models::DailyStats.create(
        date: date,
        guest_users: guest_users,
        named_users: named_users,
        new_users: new_users,
        total_active_parcels: parcels_visited,
        total_active_scenes: scenes_visited,
        unique_users: addresses.count,
      )

      nil
    end
  end
end
