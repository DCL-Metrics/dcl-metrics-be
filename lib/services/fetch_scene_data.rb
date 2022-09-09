module Services
  class FetchSceneData
    URL = 'https://peer.decentraland.org/content/entities/scene'

    def self.call(coordinates:)
      new(coordinates).call
    end

    def initialize(coordinates)
      @coordinates = coordinates
      @scenes = []
    end

    def call
      coordinates.sort.each_slice(20) do |batch|
        # check if coordinates are part of an existing scene
        coordinates_to_fetch = batch - scenes.flat_map { |s| s[:parcels] }
        next if coordinates_to_fetch.empty?

        Adapters::Dcl::Scenes.call(coordinates: coordinates_to_fetch).each do |scene|
          next if scene.nil?
          next if scene.empty?
          next if scenes.detect { |s| s['id'] == scene['id'] }

          scenes.push({
            id: scene['id'],
            name: scene['metadata']['display']['title'],
            owner: scene['metadata']['owner'],
            parcels: scene['pointers']
          })
        end
      end

      scenes
    end

    private
    attr_reader :coordinates
    attr_accessor :scenes
  end
end
