module Models
  class Event
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

      data['errors'].map { |x| x['message'] }
    end

    def serialize
      {
        enriched_data_expected: enriched_data_expected?,
        coordinates: coordinates,
        scene_uuid: scene_disambiguation_uuid,
        duration: duration_seconds,
        date: date,
        start_time: start_time,
        end_time: end_time,
        recurrent: recurrent?,
        one_off: one_off?,
        location: {
          genesis_city: genesis_city?,
          world: world?
        }
      }
    end

    def enriched_data_expected?
      return false if recurrent?
      return false unless date
      return true if Date.parse(date) > Date.parse('2022-08-01')

      false
    end

    def scene_disambiguation_uuid
      return unless enriched_data_expected?

      pt = Models::ParcelTraffic.find(coordinates: coordinates, date: date)
      pt&.scene&.scene_disambiguation_uuid
    end

    def coordinates
      # TODO: should tap scene_disambiguation_uuid or estate_id to get all coordinates
      data['position'].join(',')
    end

    def duration_seconds
      data['duration'] / 1000
    end

    def date
      if one_off?
        DateTime.parse(start_time).to_date.to_s
      else
        # TODO
      end
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
  end
end
