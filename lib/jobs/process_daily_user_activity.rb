module Jobs
  class ProcessDailyUserActivity < Job
    sidekiq_options queue: 'processing'

    def perform(address, date)
      @address = address

      data = DATABASE_CONNECTION[
        "select * from data_points
        where address = '#{@address}'
        and date = '#{date}'
        order by timestamp"
      ]

      timestamp = data.detect { |d| d[:timestamp] != nil }[:timestamp]
      return unless timestamp

      date, _time, timezone = timestamp.to_s.split
      beginning_of_day = DateTime.parse("#{date} 00:00:00 #{timezone}").to_time
      end_of_day = DateTime.parse("#{date} 23:59:59 #{timezone}").to_time

      @events = []
      prev_data_point = nil
      afk = false

      # pull any existing Models::UserEvent and add them to events array
      Models::UserEvent.where(address: address).each do |e|
        build_event(e.event, e.values)
        e.delete # ensure user events don't accumulate over time
      end

      data.each do |visit|
        # sometimes coordinates are nil
        next unless visit[:coordinates]

        if prev_data_point.nil?
          # are they in the middle of a session from the previous day?
          if within_time_delta?(visit[:timestamp], beginning_of_day, 10)
            # only build a login event around midnight if there is no existing
            # login event carried over from the previous day
            if @events.detect { |e| e[:event] == 'login' }.nil?
              build_event('login', visit)
              build_event('enter_parcel', visit)
            end

            recent_entrance = @events.detect { |e| e[:event] == 'enter_parcel' }
            if recent_entrance && recent_entrance[:coordinates] != visit[:coordinates]
              build_event('exit_parcel', visit)
              build_event('enter_parcel', visit)
            end
          else
            build_event('login', visit)
            build_event('enter_parcel', visit)
          end

        else
          case
          when prev_data_point[:position] == visit[:position] && !afk
            afk = true
            build_event('afk_start', prev_data_point)
          when prev_data_point[:position] != visit[:position] && afk
            afk = false
            build_event('afk_end', visit)
          when !within_time_delta?(prev_data_point[:timestamp], visit[:timestamp], 10)
            build_event('logout', prev_data_point)

            if afk
              afk = false
              build_event('afk_end', prev_data_point)
            end

            build_event('login', visit)
          when prev_data_point[:coordinates] != visit[:coordinates]
            build_event('exit_parcel', visit)
            build_event('enter_parcel', visit)
          # # NOTE: user can travel ~40 parcels / minute on foot and i'm taking a snapshot
          # # currently every 2.5 minutes so it's unreliable to try to calculate
          # # teleports currently
          #   build_event('teleport', visit) if teleported?(prev_data_point, visit)
          end
        end

        prev_data_point = visit
      end

      # last event is logout unless it's within 10 minutes of the end of the day
      if prev_data_point
        if prev_data_point[:timestamp]
          unless within_time_delta?(prev_data_point[:timestamp], end_of_day, 10)
            build_event('logout', prev_data_point)
            build_event('exit_parcel', prev_data_point)

            if afk
              afk = false
              build_event('afk_end', prev_data_point)
            end
          end
        else
          print "no timestamp for address #{address} on #{date}"
        end
      else
        print "no prev_data_point for address #{address} on #{date}"
      end

      create_user_activity('afk', 'afk_start', 'afk_end')
      create_user_activity('session', 'login', 'logout')
      create_user_activity('visit', 'enter_parcel', 'exit_parcel')

      # create UserEvent from any remaining events
      @events.each do |e|
        # if within_time_delta?(e[:timestamp], end_of_day, 10)
        Models::UserEvent.create(
          address: address,
          coordinates: e[:coordinates],
          event: e[:event],
          position: e[:position],
          timestamp: e[:timestamp]
        )
      end

      # TODO: separate job
      # create user tags (landowner, estateowner, golfcraft player, meta8balls player, etc)

      # TODO: separate job
      # create location tags (ex: "district", "vegas district", "chateau satoshi")
      # use POI list

      nil
    end

    private

    # TODO: probably a more efficient way to do this
    def create_user_activity(name, starting_event, ending_event)
      ending_events = @events.
        select  { |e| e[:event] == ending_event }.
        sort_by { |e| e[:timestamp] }.
        uniq

      starting_events = @events.
        select { |e| e[:event] == starting_event}.
        sort_by { |e| e[:timestamp] }.
        uniq

      return unless starting_events.any?

      ending_events.reverse.map do |e|
        start = starting_events.select { |se| se[:timestamp] < e[:timestamp] }.pop
        next unless start

        start_time = start[:timestamp]

        query = {
          name: name,
          address: @address,
          date: start_time.to_date,
          start_time: start_time,
          starting_coordinates: start[:coordinates],
          starting_position: start[:position],
        }

        Models::UserActivity.update_or_create(query) do |ua|
          ua.ending_coordinates = e[:coordinates]
          ua.ending_position = e[:position]
          ua.end_time = e[:timestamp]
          ua.duration = e[:timestamp] - start_time
        end

        @events.delete(start)
        @events.delete(e)
      end
    end

    def build_event(event_type, visit)
      @events << {
        coordinates: visit[:coordinates],
        event: event_type,
        position: visit[:position],
        timestamp: visit[:timestamp]
      }
    end

    def within_time_delta?(t1, t2, delta)
      ( t1 - t2 ).abs < ( delta * 60 )
    end

    # def teleported?(visit_a, visit_b)
    #   if separated_by_more_than_ten_minutes?(visit_a, visit_b)
    #   else
    #   end
    # end
  end
end
