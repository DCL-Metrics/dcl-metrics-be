module Jobs
  class FetchPeerData < Job
    sidekiq_options queue: 'scraping', retry: false

    def perform
      data = Adapters::AtlasCorp::Peers.fetch_snapshot

      coordinates = data.map { |c| c['parcel']&.join(',') }.compact.uniq
      scenes = Services::FetchSceneData.call(coordinates: coordinates)

      # enrich peer data with scene cid
      data.each do |d|
        next unless d['parcel']
        parcels = d['parcel'].join(',')

        scene = scenes.detect { |s| s.coordinates.split(';').include?(parcels) }
        next if scene.nil? # empty parcel
        d['scene_cid'] = scene.cid
      end

      # create peers dump
      model = Models::PeersDump.create(data_json: data.to_json)

      Jobs::ProcessSnapshot.perform_async(model.id)
    end
  end
end
