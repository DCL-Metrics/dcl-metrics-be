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
      FAT_BOY_DATABASE[
        "select distinct(address) from data_points
        where coordinates='#{coordinates}'
        and scene_cid='#{scene_cid}'
        and date='#{date}'"
      ].all.flat_map(&:values)
    end

    def histogram_json
      FAT_BOY_DATABASE[
        "select DATE_TRUNC('hour', timestamp) as hour,
        count(distinct address)
        from data_points
        where coordinates='#{coordinates}'
        and scene_cid='#{scene_cid}'
        and date = '#{date}'
        group by hour
        order by 1"
      ].all.to_json
    end
  end
end
