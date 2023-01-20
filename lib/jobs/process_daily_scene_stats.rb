module Jobs
  class ProcessDailySceneStats < Job
    sidekiq_options queue: 'processing'

    def perform(date, scene_disambiguation_uuid, cids, total_global_users)
      scene_disambiguation = Models::SceneDisambiguation.find(uuid: scene_disambiguation_uuid)
      name = scene_disambiguation.name
      coordinates = scene_disambiguation.coordinates

      scene_traffic =  Models::ParcelTraffic.where(
        coordinates: coordinates,
        date: date,
        scene_cid: cids
      )

      scene_activities = Models::UserActivity.where(
        date: date,
        starting_coordinates: coordinates
      )

      visits = scene_activities.where(name: 'visit_scene')
      afk    = scene_activities.where(name: 'afk')

      total_visitors = visits.count
      unique_visitors = visits.distinct(:address).count
      unique_visitors_afk = afk.distinct(:address).count
      unique_addresses = scene_traffic.flat_map(&:addresses).uniq.count

      if visits.any?
        # "x% of users that visited dcl today visited this scene"
        share_of_global_visitors = (unique_visitors / total_global_users.to_f) * 100

        # avg_time_spent
        total_visit_duration_seconds = visits.sum(:duration).to_i
        avg_time_spent = if total_visit_duration_seconds.zero?
          0
        else
          total_visit_duration_seconds / unique_visitors
        end

        # avg_time_spent_afk
        total_afk_duration_seconds = afk.sum(:duration).to_i
        avg_time_spent_afk = if total_afk_duration_seconds.zero?
          0
        else
          total_afk_duration_seconds / unique_visitors
        end

        # TODO: this calculation is fucked up
        # my guess is that a afk users are just getting counted more than once
        # for some reason (although i haven't been able to verify that) so that
        # there is ending up a situation where there is, for example:
        #
        # 2 unique visitors
        # 3 unique visitors afk
        # 150 percent of users afk
        #
        # this can also point to an error in the way that user activities are
        # calculated - maybe not all visitors are being counted correctly, ie,
        # the calculation for afk users is somehow more accurate ¯\_(ツ)_/¯
        #
        # % of afk users
        percent_of_users_afk = (unique_visitors_afk / unique_visitors.to_f) * 100

        # users with longest session
        visits_by_address = visits.all.group_by(&:address)
        visitors_by_duration = visits_by_address.
          map { |address, visits| [address, visits.map(&:duration).sum.to_i / 60.to_f] }.
          sort_by(&:last)

        user_visit_histogram = visitors_by_duration.
          group_by { |address, duration| (duration / 60.to_f).floor }.
          map { |k, v| [k, v.size] }
      else
        share_of_global_visitors = 0
        avg_time_spent = 0
        avg_time_spent_afk = 0
        percent_of_users_afk = 0
        visitors_by_duration = []
        user_visit_histogram = []
      end

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
      complete_sessions = Models::UserActivity.where(
        date: date,
        starting_coordinates: coordinates,
        ending_coordinates: coordinates,
        name: 'session'
      )
      total_duration_seconds = complete_sessions.sum(:duration).to_i
      avg_complete_session_duration = if total_duration_seconds.zero?
        0
      else
        total_duration_seconds / complete_sessions.count
      end

      # parcel heatmap
      parcels_heatmap = scene_traffic.
        map { |pt| [pt.coordinates, pt.unique_addresses] }.
        to_h

      visitors_by_hour_histogram = scene_traffic.
        flat_map { |pt| JSON.parse(pt.histogram_json) }.
        group_by { |h| h['hour'] }.
        map do |timestamp, data|
          hour = timestamp.split[1].split(':').first
          max_count = data.max_by { |d| d['count'] }['count']
          [hour, max_count]
        end.to_h

      Models::DailySceneStats.create(
        date: date,
        name: name,
        coordinates: coordinates.sort.join(';'),
        scene_disambiguation_uuid: scene_disambiguation_uuid,
        cids: cids.sort.join(','),
        total_visitors: total_visitors,
        unique_visitors: unique_visitors,
        unique_visitors_afk: unique_visitors_afk,
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
        visitors_by_hour_histogram_json: visitors_by_hour_histogram.to_json,
        parcels_heatmap_json: parcels_heatmap.to_json
      )

      nil
    end
  end
end
