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
        addresses_ndj: addresses_ndj,
        histogram_json: histogram_json
      )
    end

    private
    attr_reader :coordinates, :date

    def data_ndj
      DATABASE_CONNECTION[
        "select * from data_points
        where coordinates='#{coordinates}'
        and date='#{date}'"
      ].all.map(&:to_json).join("\n")
    end

    def scene_cids_json
      DATABASE_CONNECTION[
        "select * from data_points
        where coordinates='#{coordinates}'
        and date='#{date}'"
      ].all.flat_map(&:values).to_json

    end

    def addresses_ndj
      DATABASE_CONNECTION[
        "select distinct(address) from data_points
        where coordinates='#{coordinates}'
        and date='#{date}'"
      ].all.map(&:to_json).join("\n")
    end

    def histogram_json
      DATABASE_CONNECTION[
        "select DATE_TRUNC('hour', timestamp) as hour,
        count(id)
        from data_points
        where coordinates='#{coordinates}'
        and date = '#{date}'
        group by hour
        order by 1"
      ].all.to_json
    end
  end
end
