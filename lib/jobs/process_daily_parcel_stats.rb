module Jobs
  class ProcessDailyParcelStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      time_spent = USER_ACTIVITIES_DATABASE[
        "select
          starting_coordinates as coordinates,
          count(distinct address) as visits,
          sum(duration) AS time_spent
        from user_activities
        where name = 'visit'
        and start_time >= '#{date} 00:00:00'
        and start_time <= '#{date} 23:59:00'
        group by coordinates
        order by time_spent desc
        limit 10"
      ].all

      top_coordinates = time_spent.
        map { |ts| ts[:coordinates] }.
        to_s.
        sub("[", "(").
        sub("]",")").
        gsub('"',"'")

      time_spent_afk = USER_ACTIVITIES_DATABASE[
        "select
          starting_coordinates as coordinates,
          count(distinct address) as afk_visitors,
          sum(duration) AS time_spent_afk
        from user_activities
        where starting_coordinates in #{top_coordinates}
        and name = 'afk'
        and start_time >= '#{date} 00:00:00'
        and start_time <= '#{date} 23:59:00'
        group by coordinates
        order by time_spent_afk desc
        limit 10"
      ].all

      unique_visitors = FAT_BOY_DATABASE[
        "select coordinates, count(distinct address) AS unique_visitors
        from data_points
        where date = '#{date}'
        group by coordinates
        order by unique_visitors desc
        limit 10"
      ].all

      top_login_locations = USER_ACTIVITIES_DATABASE[
        "select
          starting_coordinates as coordinates,
          count(distinct address) as logins
        from user_activities
        where name = 'session'
        and start_time >= '#{date} 00:00:00'
        and start_time <= '#{date} 23:59:00'
        group by coordinates
        order by logins desc
        limit 10"
      ].all

      top_logout_locations = USER_ACTIVITIES_DATABASE[
        "select
          ending_coordinates as coordinates,
          count(distinct address) as logouts
        from user_activities
        where name = 'session'
        and start_time >= '#{date} 00:00:00'
        and start_time <= '#{date} 23:59:00'
        group by coordinates
        order by logouts desc
        limit 10"
      ].all

      # doing it this way cause there is generally going to be a lot of overlap
      # here but not necessarily - so normally will make ~12-15 rows in day.
      # total overlap would create 10
      results = (
        time_spent +
        time_spent_afk +
        unique_visitors +
        top_login_locations +
        top_logout_locations
      )

      results.group_by { |h| h[:coordinates] }.each do |c, values|
        values = values.reduce(Hash.new, :merge)

        avg_time_spent = if values[:time_spent]
          values[:time_spent] / values[:visits]
        end

        avg_time_spent_afk = if values[:time_spent_afk]
          values[:time_spent_afk] / values[:afk_visitors]
         end

        Models::DailyParcelStats.create(
          date: date,
          coordinates: c,
          avg_time_spent: avg_time_spent,
          avg_time_spent_afk: avg_time_spent_afk,
          unique_visitors: values[:unique_visitors],
          logins: values[:logins],
          logouts: values[:logouts]
        )
      end

      nil
    end
  end
end
