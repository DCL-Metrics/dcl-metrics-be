module Services
  class FetchSceneData
    URL = 'https://peer.decentraland.org/content/entities/scene'

    def self.call(coordinates:)
      new(coordinates).call
    end

    def initialize(coordinates)
      @coordinates = coordinates.uniq.sort
      @current_time = Time.now.utc
      @scenes = []
    end

    def call
      Adapters::Dcl::Scenes.call(coordinates: coordinates).each do |scene|
        next if scene.nil?
        next if scene.empty?
        next if scenes.detect { |s| s.cid == scene['id'] } # don't process dups

        # create scene if unknown and add to result collection
        find_or_create_scene(scene)
      end

      scenes
    end

    private
    attr_reader :coordinates, :current_time
    attr_accessor :scenes

    def find_or_create_scene(scene)
      begin
        name = scene['metadata']['display']['title']
        coordinates = scene['pointers'].sort.join(';')
        scene_disambiguation_uuid = find_or_create_scene_uuid(name, coordinates)

        model = Models::Scene.find_or_create(cid: scene['id']) do |s|
          s.name                      = name
          s.owner                     = scene['metadata']['owner']
          s.coordinates               = coordinates
          s.first_seen_at             = current_time
          s.first_seen_on             = current_time.to_date.to_s
          s.scene_disambiguation_uuid = scene_disambiguation_uuid
        end

        scenes.push(model)
      rescue Sequel::UniqueConstraintViolation
        scenes.push(Models::Scene.find(cid: scene['id']))
      end
    end

    def find_or_create_scene_uuid(name, coordinates)
      params = { name: name, coordinates: coordinates }

      model = Models::SceneDisambiguation.find_or_create(params) do |sd|
        sd.uuid = SecureRandom.uuid
      end

      model.uuid
    end
  end
end
