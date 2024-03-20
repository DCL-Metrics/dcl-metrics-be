# there are a few branching paths that will determine data depth:
# 1. upcoming vs live vs completed - full data is only available for completed events after 2022-08
# 2. worlds vs genesis city - worlds has less data
# 3. one_off vs recurrent - recurrent events have a slightly different structure
# so have to understand how to correctly pull data related to them

class Event
  def initialize(id)
    @id = id
    @url = "https://events.decentraland.org/api/events/#{id}"

    # initialize data
    data
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

current_event_id = 'a5033b5f-fce5-4685-ada5-5d33081d6c10'
past_event_id = '00cb4198-690a-4826-8127-192b60c8cc05'  # before august 2022
past_event_id = '97ab2d15-ddc7-4b49-b913-faf2ff89af79' # after august 2022

e = Event.new(past_event_id)

# TODO: figure out date query, espeically in the case of events
# that span (1) only a few hours or (2) several days.
# TODO: if this event was in a world, query will look different and in both
# cases, the final result should be serialized
# TODO: will have to pull data points from backblaze to get precise data about
# what users were part of an event and which were not
pt = Models::ParcelTraffic.find(coordinates: e.coordinates, date: e.date)

# TODO: at the end it makes much more sense to fetch events which a given scene
# or coordiante hosted, rather than finding events and then finding which scene
# it happened on. not that this isn't a valid usecase, it's just a much more
# limited one and one which doesn't necessarily make sense in the context of our app
# can be nil
Models::DailySceneStats.find(scene_disambiguation_uuid: pt.scene.scene_disambiguation_uuid, date: e.date)

# or get all other parcel traffic models
Models::ParcelTraffic.where(date: pt.date, scene_cid: pt.scene_cid)

######################
## recurrent events
######################

start_of_event_series = DateTime.parse(e.data['recurrent_dates'][0])
end_of_event_series = DateTime.parse(e.data['recurrent_dates'][1])

# TODO: based on recurrent interval and recurrent frequency, filter out dates
# from the range until left with all the dates on which an event occurs.
# then use "duration" to calcuate the start/end time for an event on a given day
# logically it's something like "every #{interval} #{frequency}", like "every 3
# days" or "every 1 week"

occurrences = []
occurrence = start_of_event_series

while occurrence <= end_of_event_series do
  occurrences << {
    start_time: occurrence,
    end_time: (occurrence.to_time + e.duration_seconds).to_datetime
  }

  frequency = {
    'DAILY' => 'day',
    'WEEKLY' => 'week',
    'MONTHLY' => 'month',
    'YEARLY' => 'year'
  }[e.data['recurrent_frequency']]

  occurrence = occurrence.send("next_#{frequency}".to_sym, e.data['recurrent_interval'])

  print "#{occurrence}\n"
end

####

id = "01cec170-01ef-4089-836a-07ac6467539d" # recurring every week for several weeks
id = "c23d5a88-9e68-47d6-9b01-a45ca18b2731" # also recurring every week, but uses daily / 7 interval
id = "0baffaa7-b9e5-4ada-9c98-f25d6e79c354" # recurring every day for several weeks

e = Models::Event.new(id)

