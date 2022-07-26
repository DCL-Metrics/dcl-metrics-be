module Services
  class CreateScenesOnDate
    URL = 'https://peer.decentraland.org/content/entities/scene?pointer='

    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @date = date
      @scenes = []
    end

    def call
      coordinates = DATABASE_CONNECTION[
        "select distinct coordinates from data_points where date = '#{date}'"
      ].flat_map(&:values)

      coordinates.each do |c|
        # check if coordinates are part of an existing scene
        next if scenes.any? { |s| s[:parcels].include?(c) }

        # get data from url
        scene_data = JSON.parse(`curl #{URL}#{c}`)[0]

        # skip if there is no scene at these cooridinates
        next if scene_data.empty?

        # add scene to scenes
        scenes << {
          name: scene_data['metadata']['display']['title'],
          owner: scene_data['metadata']['owner'],
          parcels: scene_data['pointers']
        }
      end

      # create scene list
      Models::SceneList.create(
        date: date,
        scenes_json: scenes.to_json
      )
    end

    private
    attr_reader :date
    attr_accessor :scenes
  end
end
