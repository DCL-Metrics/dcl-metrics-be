module Services
  class CreateDailyParcelTraffic
    def self.call(coordinates:, date:)
      new(coordinates, date).call
    end

    def initialize(coordinates, date)
      @coordinates = coordinates
      @date = date
    end

    def call
      Models::ParcelTraffic.create(
        coordinates: coordinates,
        date: date,
        data_ndj: data_ndj,
        scene_cids_json: scene_cids_json,
        addresses_json: addresses.to_json,
        histogram_json: histogram_json,
        unique_addresses: addresses.count
      )
    end

    private
    attr_reader :coordinates, :date

    def data_ndj
      FAT_BOY_DATABASE[
        "select * from data_points
        where coordinates='#{coordinates}'
        and date='#{date}'"
      ].all.map(&:to_json).join("\n")
    end

    def scene_cids_json
      FAT_BOY_DATABASE[
        "select distinct(scene_cid) from data_points
        where coordinates='#{coordinates}'
        and date='#{date}'"
      ].all.flat_map(&:values).to_json
    end

    def addresses
      FAT_BOY_DATABASE[
        "select distinct(address) from data_points
        where coordinates='#{coordinates}'
        and date='#{date}'"
      ].all.flat_map(&:values)
    end

    def histogram_json
      FAT_BOY_DATABASE[
        "select DATE_TRUNC('hour', timestamp) as hour,
        count(distinct address)
        from data_points
        where coordinates='#{coordinates}'
        and date = '#{date}'
        group by hour
        order by 1"
      ].all.to_json
    end
  end
end
