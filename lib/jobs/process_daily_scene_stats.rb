module Jobs
  class ProcessDailySceneStats < Job
    sidekiq_options queue: 'processing'

    def perform(date, name, coordinates, cids, total_global_users)
      scene_traffic =  Models::ParcelTraffic.where(coordinates: coordinates, date: date)
      scene_activities = Models::UserActivity.where(
        date: date,
        starting_coordinates: coordinates,
        ending_coordinates: coordinates
      )

      # NOTE: "total visitors" is not entirely correct.
      # this is all visits within the parcels of the scene,
      # so if i jump back and forth between coordinates within the scene 10 times
      # that counts as ten visits but the borders should be
      # if someone exits the scene as a whole
      total_visitors = scene_activities.where(name: 'visit').count
      unique_visitors = scene_activities.where(name: 'visit').distinct(:address).count
      unique_addresses = scene_traffic.flat_map(&:addresses).uniq.count

      # "x% of users that visited dcl today visited this scene"
      share_of_global_visitors = (unique_visitors / total_global_users.to_f) * 100

      # avg_time_spent
      total_visit_duration_seconds = scene_activities.where(name: 'visit').sum(:duration)
      avg_time_spent = (total_visit_duration_seconds / 60) / total_visitors.to_f

      # avg_time_spent_afk
      total_afk_duration_seconds = scene_activities.where(name: 'afk').sum(:duration)
      avg_time_spent_afk = (total_afk_duration_seconds / 60) / total_visitors.to_f

      # % of afk users
      total_afk_users = scene_activities.where(name: 'afk').distinct(:address).count
      percent_of_users_afk = (total_afk_users / unique_visitors.to_f) * 100

      # logins:
      session_starts = Models::UserActivity.
        where(date: date, starting_coordinates: coordinates, name: 'session')

      total_logins = session_starts.count
      unique_logins = session_starts.distinct(:address).count

      # logouts:
      session_ends = Models::UserActivity.
        where(date: date, ending_coordinates: coordinates, name: 'session')

      total_logouts = session_ends.count
      unique_logouts = session_ends.distinct(:address).count

      # complete sessions (user logged in and logged out from this scene - not unique):
      complete_sessions = scene_activities.where(name: 'session')
      if complete_sessions.any?
        total_duration = complete_sessions.sum(:duration) / 60
        avg_complete_session_duration = total_duration / complete_sessions.count.to_f
      else
        avg_complete_session_duration = nil
      end

      # users with longest session
      visits_by_address = scene_activities.where(name: 'visit').all.group_by(&:address)
      visitors_by_duration = visits_by_address.
        map { |address, visits| [address, visits.map(&:duration).sum / 60] }.
        sort_by(&:last)

      user_visit_histogram = visitors_by_duration.
        group_by { |address, duration| (duration / 60.to_f).floor }.
        map { |k, v| [k, v.size] }

      # parcel heatmap
      parcels_heatmap = scene_traffic.
        map { |pt| [pt.coordinates, pt.unique_addresses] }.
        to_h

      Models::DailySceneStats.create(
        name: name,
        coordinates: coordinates.sort.join(';'),
        cids: cids.sort.join(','),
        total_visitors: total_visitors,
        unique_visitors: unique_visitors,
        unique_addresses: unique_addresses,
        share_of_global_visitors: share_of_global_visitors,
        avg_time_spent: avg_time_spent,
        avg_time_spent_afk: avg_time_spent_afk,
        percent_of_users_afk: percent_of_users_afk,
        total_logins: total_logins,
        unique_logins: unique_logins,
        total_logouts: total_logouts,
        unique_logouts: unique_logouts,
        complete_sessions: complete_sessions.count,
        avg_complete_session_duration: avg_complete_session_duration,
        visitors_by_total_time_spent_json: visitors_by_duration.to_h.to_json,
        visitors_total_time_spent_histogram_json: user_visit_histogram.to_json,
        parcels_heatmap_json: parcels_heatmap.to_json
      )

      nil
    end
  end
end
