module Jobs
  class FetchPeerData < Job
    sidekiq_options queue: 'scraping'

    def perform
      data = Adapters::Dcl::Peers.fetch_snapshot

      coordinates = data.map { |c| c['parcel']&.join(',') }.compact
      scenes = Services::FetchSceneData.call(coordinates: coordinates)

      # enrich peer data with scene cid
      data.each do |d|
        next unless d['parcel']

        scene = scenes.detect { |s| s.parcels.include?(d['parcel'].join(',')) }
        next if scene.nil? # empty parcel
        d['scene_cid'] = scene.cid
      end

      # create peers dump
      Models::PeersDump.create(data_json: data.to_json)
    end
  end
end
