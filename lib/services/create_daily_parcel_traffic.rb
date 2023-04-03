module Services
  class CreateDailyParcelTraffic
    def self.call(coordinates:, date:, scene_cid:)
      new(coordinates, date, scene_cid).call
    end

    def initialize(coordinates, date, scene_cid)
      @coordinates = coordinates
      @date = date
      @scene_cid = scene_cid
    end

    def call
      Models::ParcelTraffic.create(
        coordinates: coordinates,
        date: date,
        scene_cid: scene_cid,
        addresses_json: addresses.to_json,
        histogram_json: histogram.to_json,
        max_concurrent_users: max_concurrent_users,
        unique_addresses: addresses.count
      )
    end

    private
    attr_reader :coordinates, :date, :scene_cid

    def addresses
      Models::DataPoint.
        where(coordinates: coordinates).
        where(scene_cid: scene_cid).
        where(date: date).
        select(:address).
        distinct.
        all.
        flat_map { |x| x.values.values }
    end

    def peer_stats_data
      @peer_stats_data ||= Models::PeerStats.find(
        date: date,
        coordinates: coordinates,
        scene_cid: scene_cid
      )&.data
    end

    def histogram
      return @histogram if defined?(@histogram)

      query = scene_cid.nil? ? histo_query_with_no_cid : histo_query_with_cid
      @histogram = FAT_BOY_DATABASE[query].all
    end

    def max_concurrent_users
      peer_stats_data&.values&.max || histogram.max_by { |x| x[:count] }[:count]
    end

    def histo_query_with_cid
      "select DATE_TRUNC('hour', timestamp) as hour,
      count(distinct address)
      from data_points
      where coordinates='#{coordinates}'
      and scene_cid='#{scene_cid}'
      and date = '#{date}'
      group by hour
      order by 1"
    end

    def histo_query_with_no_cid
      "select DATE_TRUNC('hour', timestamp) as hour,
      count(distinct address)
      from data_points
      where coordinates='#{coordinates}'
      and date = '#{date}'
      group by hour
      order by 1"
    end
  end
end
