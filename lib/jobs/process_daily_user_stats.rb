module Jobs
  class ProcessDailyUserStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      time_spent = FAT_BOY_DATABASE[
        "select address, sum(duration) AS time_spent
        from user_activities
        where name = 'session'
        and date = '#{date}'
        group by address"
      ].all

      time_spent_afk = FAT_BOY_DATABASE[
        "select address, sum(duration) AS time_spent_afk
        from user_activities
        where name = 'afk'
        and date = '#{date}'
        group by address"
      ].all

      parcels_visited = FAT_BOY_DATABASE[
        "select address, count(distinct coordinates) AS parcels_visited
        from data_points
        where date = '#{date}'
        group by address"
      ].all

      scenes_visited = FAT_BOY_DATABASE[
        "select address, count(distinct scene_cid) AS scenes_visited
        from data_points
        where date = '#{date}'
        group by address"
      ].all

      grouped = (time_spent + time_spent_afk + parcels_visited + scenes_visited).
        flatten.
        group_by { |x| x[:address] }

      grouped.each do |address, rows|
        next if address.nil?
        data = Hash.new.merge(*rows)

        Models::DailyUserStats.create(
          date: date,
          address: address,
          time_spent: data[:time_spent] || 1,
          time_spent_afk: data[:time_spent_afk] || 0,
          parcels_visited: data[:parcels_visited],
          scenes_visited: data[:scenes_visited]
        )
      end

      nil
    end
  end
end
