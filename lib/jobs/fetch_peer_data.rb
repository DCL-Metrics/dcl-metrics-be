module Jobs
  class FetchPeerData < Job
    sidekiq_options queue: 'scraping'

    def perform
      data = Adapters::Dcl::Peers.fetch_snapshot

      first_seen_at = Time.now.utc
      coordinates = data.map { |c| c['parcel']&.join(',') }.compact
      scenes = Services::FetchSceneData.call(coordinates: coordinates)

      # enrich peer data with scene cid
      data.each do |d|
        next unless d['parcel']

        scene = scenes.detect { |s| s[:parcels].include?(d['parcel'].join(',')) }
        next if scene.nil? # empty parcel
        d['scene_cid'] = scene[:id]
      end

      # create peers dump
      Models::PeersDump.create(data_json: data.to_json)

      # create any unknown scenes
      scenes.each do |scene|
        Models::Scene.find_or_create(cid: scene[:id]) do |s|
          s.name          = scene[:name]
          s.owner         = scene[:owner]
          s.parcels_json  = scene[:parcels].to_json
          s.first_seen_at = first_seen_at
          s.first_seen_on = first_seen_at.to_date.to_s
        end
      end
    end
  end
end
