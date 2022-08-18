module Jobs
  class FetchPeerData < Job
    sidekiq_options queue: 'scraping'

    SERVERS = %w[
      "https://peer-ec1.decentraland.org"
      "https://peer-ec2.decentraland.org"
      "https://peer-wc1.decentraland.org"
      "https://peer-eu1.decentraland.org"
      "https://peer-ap1.decentraland.org"
      "https://interconnected.online"
      "https://peer.decentral.io"
      "https://peer.melonwave.com"
      "https://peer.kyllian.me"
      "https://peer.uadevops.com"
      "https://peer.dclnodes.io"
    ]

    def perform
      data = SERVERS.flat_map do |host|
        raw_data = `curl -s #{host}/comms/peers`

        begin
          data = JSON.parse(raw_data)
        rescue JSON::ParserError
          next
        end

        next if data.class == Array
        data['peers'] if data['ok'] if data.class == Hash
      end.compact

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
          s.parcels       = scene[:parcels].to_json
          s.first_seen_at = first_seen_at
          s.first_seen_on = first_seen_at.to_date.to_s
        end
      end
    end
  end
end
