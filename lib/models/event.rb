module Models
  class Event
    def self.count
      # implemented to not break syntax of normal model
    end

    # TODO: so in theory this is acting as a model with an api as the storage
    # method rather than a database. however, the "database fetching" mechanism
    # - in this case pulling with Faraday - should be abstracted to an adapter
    def initialize(id)
      @id = id
      @url = "https://events.decentraland.org/api/events/#{id}"

      # initialize data
      data
    end

    def errors
      return [] unless data['errors']

      data['messages']
    end

    def serialize
      {
        coordinates: coordinates,
        occurrences: serialize_occurrences,
        location: {
          genesis_city: genesis_city?,
          world: world?
        }
      }
    end

    def coordinates
      # TODO: should tap scene_disambiguation_uuid or estate_id to get all coordinates
      data['position'].join(',')
    end

    def duration_seconds
      data['duration'] / 1000
    end

    def occurrences
      if one_off?
        start = DateTime.parse(start_time)
        @occurrences = [{
          start_time: start,
          end_time: (start.to_time + duration_seconds).to_datetime
        }]
      end

      return @occurrences if defined?(@occurrences)

      @occurrences = []
      start_of_event_series = DateTime.parse(data['recurrent_dates'][0])
      end_of_event_series = DateTime.parse(data['recurrent_dates'][1])
      occurrence = start_of_event_series
      frequency = {
        'DAILY' => 'day',
        'WEEKLY' => 'week',
        'MONTHLY' => 'month',
        'YEARLY' => 'year'
      }[data['recurrent_frequency']]

      while occurrence <= end_of_event_series do
        @occurrences << {
          start_time: occurrence,
          end_time: (occurrence.to_time + duration_seconds).to_datetime
        }

        occurrence = occurrence.send("next_#{frequency}".to_sym, data['recurrent_interval'])
      end

      @occurrences
    end

    def start_time
      data['start_at']
    end

    def end_time
      data['finish_at']
    end

    def recurrent?
      data['recurrent']
    end

    def one_off?
      !recurrent?
    end

    def live?
      data['live']
    end

    def world?
      data['world']
    end

    def genesis_city?
      !world?
    end

    def data
      return @data unless @data.nil?

      response = Faraday.get(url)
      @data = JSON.parse(response.body)['data']
    end

    private
    attr_reader :id, :url

    def serialize_occurrences
      occurrences.map do |o|
        date = o[:start_time].to_date.to_s

        {
          scene_uuid: scene_disambiguation_uuid(date),
          date: date,
          duration: duration_seconds,
          start_time: o[:start_time],
          end_time: o[:end_time]
        }
      end
    end

    def enriched_data_expected?(date)
      return false unless date
      return true if Date.parse(date) > Date.parse('2022-08-01')

      false
    end

    def scene_disambiguation_uuid(date)
      return unless enriched_data_expected?(date)

      pt = Models::ParcelTraffic.find(coordinates: coordinates, date: date)
      pt&.scene&.scene_disambiguation_uuid
    end
  end
end
