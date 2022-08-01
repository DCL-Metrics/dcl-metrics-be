module Services
  class CreateScenesOnDate
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @date = date
    end

    def call
      coordinates = DATABASE_CONNECTION[
        "select distinct coordinates from data_points where date = '#{date}'"
      ].flat_map(&:values)

      scenes = Services::FetchSceneData.call(coordinates: coordinates)

      scenes.each do |scene|
        Models::Scene.find_or_create(cid: scene[:id]) do |s|
          s.name          = scene[:name]
          s.owner         = scene[:owner]
          s.parcels       = scene[:parcels].to_json
          s.first_seen_on = date
        end
      end
    end

    private
    attr_reader :date
  end
end
