module Jobs
  class ProcessDailyStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      unique_users = DATABASE_CONNECTION[
        "select distinct address from data_points where date = '#{date}'"
      ].count

      parcels_visited = DATABASE_CONNECTION[
        "select distinct coordinates from data_points where date = '#{date}'"
      ].count

      Models::DailyStats.create(
        date: date,
        unique_users: unique_users,
        total_active_parcels: parcels_visited
      )

      nil
    end
  end
end
