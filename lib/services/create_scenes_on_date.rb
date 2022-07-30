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

      # create scene list
      Models::SceneList.create(
        date: date,
        scenes_json: scenes.to_json
      )
    end

    private
    attr_reader :date
  end
end
