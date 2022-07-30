module Services
  class FetchSceneData
    URL = 'https://peer.decentraland.org/content/entities/scene'

    def self.call(coordinates:)
      new(coordinates).call
    end

    def initialize(coordinates)
      @coordinates = coordinates
    end

    def call
      scenes = []
      pointers = coordinates.map { |x| "pointer=#{x}" }.join('&')
      request = `curl -s -G #{URL} -d "query=#{pointers}"`
      scene_data = JSON.parse(request).uniq { |s| s['id'] }

      scene_data.each do |scene|
        scenes.push({
          id: scene_data['id'],
          name: scene_data['metadata']['display']['title'],
          owner: scene_data['metadata']['owner'],
          parcels: scene_data['pointers']
        })
      end

      scenes
    end

    private
    attr_reader :coordinates
  end
end
