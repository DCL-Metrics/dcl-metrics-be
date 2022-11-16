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
        histogram_json: histogram_json,
        unique_addresses: addresses.count
      )
    end

    private
    attr_reader :coordinates, :date, :scene_cid

    def addresses
      base_query = Models::DataPoint.
        where(coordinates: coordinates).
        where(date: date).
        where(scene_cid: scene_cid).
        select(:address).
        distinct.
        all.
        flat_map { |x| x.values.values }
    end

    def histogram_json
      query = scene_cid.nil? ? query_with_no_scene_cid : query_with_scene_cid
      FAT_BOY_DATABASE[query].all.to_json
    end

    def query_with_scene_cid
      "select DATE_TRUNC('hour', timestamp) as hour,
      count(distinct address)
      from data_points
      where coordinates='#{coordinates}'
      and scene_cid='#{scene_cid}'
      and date = '#{date}'
      group by hour
      order by 1"
    end

    def query_with_no_scene_cid
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
