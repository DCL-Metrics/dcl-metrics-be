module Jobs
  class ProcessDailyUserActivity < Job
    def perform(address, date)
      data = DATABASE_CONNECTION[
        "select * from data_points
        where address = '#{address}'
        and date = '#{date}'
        order by timestamp"
      ]

      # for local testing
      # raw_data = JSON.parse(File.read('./user_activity_fixture.json'))
      # data = JSON.parse(raw_data)

      date, _time, timezone = data.first[:timestamp].to_s.split
      beginning_of_day = DateTime.parse("#{date} 00:00:00 #{timezone}").to_time
      end_of_day = DateTime.parse("#{date} 23:59:59 #{timezone}").to_time

      prev_data_point = nil
      afk = false

      data.each do |visit|
        # sometimes coordinates are nil
        next unless visit[:coordinates]

        if prev_data_point.nil?
          # are they in the middle of a session from the previous day?
          if within_time_delta?(visit[:timestamp], beginning_of_day, 10)
            create_event('enter_parcel', address, visit)
          else
            create_event('login', address, visit)
            create_event('enter_parcel', address, visit)
          end
        else
          case
          when prev_data_point[:position] == visit[:position] && !afk
            afk = true
            create_event('afk_start', address, prev_data_point)
          when prev_data_point[:position] != visit[:position] && afk
            afk = false
            create_event('afk_end', address, visit)
          when !within_time_delta?(prev_data_point[:timestamp], visit[:timestamp], 10)
            create_event('logout', address, prev_data_point)

            if afk
              afk = false
              create_event('afk_end', address, prev_data_point)
            end

            create_event('login', address, visit)
          when prev_data_point[:coordinates] != visit[:coordinates]
            create_event('enter_parcel', address, visit)
          # # NOTE: user can travel ~40 parcels / minute on foot and i'm taking a snapshot
          # # currently every 2.5 minutes so it's unreliable to try to calculate
          # # teleports currently
          #   create_event('teleport', address, visit) if teleported?(prev_data_point, visit)
          end
        end

        prev_data_point = visit
      end

      # skip if there was no previous datapoint for this address
      # (how is that the case though..?)
      unless prev_data_point.nil?
        # last event is logout unless it's within 10 minutes of the end of the day
        unless within_time_delta?(prev_data_point[:timestamp], end_of_day, 10)
          create_event('logout', address, prev_data_point)

          if afk
            afk = false
            create_event('afk_end', address, prev_data_point)
          end
        end
      end

      nil

      # create user activity:
      # parcel enter_at exit_at duration user_id

      # TODO: separate job
      # create user tags (landowner, estateowner, golfcraft player, meta8balls player, etc)

      # TODO: separate job
      # create location tags (ex: "district", "vegas district", "chateau satoshi")
    end

    private

    def create_event(event_type, address, visit)
      Models::UserEvent.create(
        address: address,
        coordinates: visit[:coordinates],
        event: event_type,
        timestamp: visit[:timestamp]
      )
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
