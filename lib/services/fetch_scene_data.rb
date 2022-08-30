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
        c = batch - scenes.flat_map { |s| s[:parcels] }
        next if c.empty?

        # get data from url
        # if there is only one element in the array the request needs
        # to be in a different format for whatever reason :shrug:
        if c.count == 1
          request = `curl -s "#{URL}?pointer=#{c.join(',')}"`
        else
          pointers = c.map { |x| "pointer=#{x}" }.join('&')
          request = `curl -s -G #{URL} -d "query=#{pointers}"`
        end

        scene_data = JSON.parse(request).compact

        scene_data.each do |scene|
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
