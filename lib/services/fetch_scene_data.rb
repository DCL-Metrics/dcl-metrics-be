module Services
  class FetchSceneData
    URL = 'https://peer.decentraland.org/content/entities/scene'

    def self.call(coordinates:)
      new(coordinates).call
    end

    def initialize(coordinates)
      @coordinates = coordinates.uniq
      @current_time = Time.now.utc
      @scenes = []
    end

    def call
      coordinates.sort.each_slice(40) do |batch|
        # check if coordinates are part of an existing scene
        coordinates_to_fetch = batch - scenes.flat_map(&:parcels)
        next if coordinates_to_fetch.empty?

        Adapters::Dcl::Scenes.call(coordinates: coordinates_to_fetch).each do |scene|
          next if scene.nil?
          next if scene.empty?
          next if scenes.detect { |s| s.cid == scene['id'] }

          # create scene if unknown and add to result collection
          find_or_create_scene(scene)
        end
      end

      scenes
    end

    private
    attr_reader :coordinates, :current_time
    attr_accessor :scenes

    def find_or_create_scene(scene)
      begin
        model = Models::Scene.find_or_create(cid: scene['id']) do |s|
          s.name          = scene['metadata']['display']['title']
          s.owner         = scene['metadata']['owner']
          s.parcels_json  = scene['pointers'].to_json
          s.first_seen_at = current_time
          s.first_seen_on = current_time.to_date.to_s
        end

        scenes.push(model)
      rescue Sequel::UniqueConstraintViolation
        scenes.push(Models::Scene.find(cid: scene['id']))
      end
    end
  end
end
