module Jobs
  class ProcessDailyUserActivity < Job
    sidekiq_options queue: 'processing'

    def perform(address, date)
      @address = address

      data = FAT_BOY_DATABASE[
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
              build_event('enter_scene', visit) unless visit[:scene_cid].nil?
            end

            # recent parcel entrance
            rpe = @events.detect { |e| e[:event] == 'enter_parcel' }
            if rpe && rpe[:coordinates] != visit[:coordinates]
              build_event('exit_parcel', visit)
              build_event('enter_parcel', visit)
            end

            # recent scene entrance
            rse = @events.detect { |e| e[:event] == 'enter_scene' }
            if rse && rse[:scene_cid] != visit[:scene_cid]
              build_event('exit_scene', visit)
              build_event('enter_scene', visit) unless visit[:scene_cid].nil?
            end
          else # not within time delta, ie no carry-over session
            build_event('login', visit)
            build_event('enter_parcel', visit)
            build_event('enter_scene', visit) unless visit[:scene_cid].nil?
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
          when prev_data_point[:scene_cid] != visit[:scene_cid]
            build_event('exit_scene', visit)
            build_event('enter_scene', visit) unless visit[:scene_cid].nil?
          when prev_data_point[:coordinates] != visit[:coordinates]
            build_event('exit_parcel', visit)
            build_event('enter_parcel', visit)
            # TODO NOTE: experimental - detect teleports
            # build_event('teleport', visit) if teleported?(prev_data_point, visit)
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
            build_event('exit_scene', prev_data_point) unless prev_data_point[:scene_cid].nil?

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
      create_user_activity('visit_scene', 'enter_scene', 'exit_scene')

      # create UserEvent from any remaining events
      @events.each do |e|
        if within_time_delta?(e[:timestamp], end_of_day, 30)
          Models::UserEvent.create(
            address: address,
            coordinates: e[:coordinates],
            event: e[:event],
            position: e[:position],
            timestamp: e[:timestamp]
          )
        end
      end

      # create visit events when a user enters but doesn't leave
      # more like an "appearance" - it will be updated the next time user
      # activities run
      @events.select { |e| e[:event] == 'enter_parcel' }.each do |e|
        query = {
          name: 'visit',
          address: @address,
          date: e[:timestamp].to_date,
          start_time: e[:timestamp],
          starting_coordinates: e[:coordinates],
          starting_position: e[:position],
        }

        save_user_activity(query, e, 1)
      end

      # do the same for visit scene
      # TODO: this could be better - see user activity spec
      @events.select { |e| e[:event] == 'enter_scene' }.each do |e|
        query = {
          name: 'visit_scene',
          address: @address,
          date: e[:timestamp].to_date,
          start_time: e[:timestamp],
          starting_coordinates: e[:coordinates],
          starting_position: e[:position],
        }

        save_user_activity(query, e, 1)
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

      return if starting_events.none?

      ending_events.reverse.map do |e|
        start = starting_events.select { |se| se[:timestamp] < e[:timestamp] }.pop
        next unless start

        start_time = start[:timestamp]
        duration = e[:timestamp] - start_time

        query = {
          name: name,
          address: @address,
          date: start_time.to_date,
          start_time: start_time,
          starting_coordinates: start[:coordinates],
          starting_position: start[:position],
        }

        save_user_activity(query, e, duration)

        @events.delete(start)
        @events.delete(e)
      end
    end

    def save_user_activity(query, e, duration)
      Models::UserActivity.update_or_create(query) do |ua|
        ua.ending_coordinates = e[:coordinates]
        ua.ending_position = e[:position]
        ua.end_time = e[:timestamp]
        ua.duration = duration
        ua.scene_cid = e[:scene_cid]
      end
    end

    def build_event(event_type, visit)
      @events << {
        coordinates: visit[:coordinates],
        event: event_type,
        position: visit[:position],
        scene_cid: visit[:scene_cid],
        timestamp: visit[:timestamp]
      }
    end

    def within_time_delta?(t1, t2, delta)
      ( t1 - t2 ).abs < ( delta * 60 )
    end

    def teleported?(visit_a, visit_b)
      return false unless within_time_delta?(visit_a[:timestamp], visit_b[:timestamp], 1)

      positions_a = visit_a[:position].split(',').map(&:to_i)
      positions_b = visit_b[:position].split(',').map(&:to_i)

      x = (positions_b[0] - positions_a[0]).abs
      y = (positions_b[2] - positions_a[2]).abs

      return true if x > 250
      return true if y > 250
      return true if Math.sqrt(x ** 2 + y ** 2) > 250

      false
    end
  end
end
