module Jobs
  class ProcessParcelStats < Job
    sidekiq_options queue: 'processing'

    def perform(date, coordinates)
      models = Models::ParcelTraffic.where(date: date, coordinates: coordinates).all

      # user activities
      visits = Models::UserActivity.
        where(date: date, starting_coordinates: coordinates, name: 'visit')
      afk = Models::UserActivity.
        where(date: date, starting_coordinates: coordinates, name: 'afk')
      logins = Models::UserActivity.
        where(date: date, starting_coordinates: coordinates, name: 'session')
      logouts = Models::UserActivity.
        where(date: date, ending_coordinates: coordinates, name: 'session')

      avg_time_spent = visits.map(&:duration).sum / visits.count.to_f
      avg_time_spent_afk = afk.map(&:duration).sum / afk.count.to_f

      Models::DailyParcelStats.create(
        avg_time_spent: calculate_time_spent(avg_time_spent),
        avg_time_spent_afk: calculate_time_spent(avg_time_spent_afk),
        coordinates: coordinates,
        date: date,
        deploy_count: models.map(&:scene_cid).uniq.count - 1,
        scene_cid: models.max_by(&:created_at).scene_cid,
        logins: logins.count,
        logouts: logouts.count,
        max_concurrent_users: models.max_by(&:max_concurrent_users).max_concurrent_users,
        unique_visitors: models.map(&:unique_addresses).sum,
      )
    end

    private

    def calculate_time_spent(time_spent)
      time_spent.nan? ? 0 : time_spent.round
    end
  end
end
