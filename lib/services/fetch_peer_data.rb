module Services
  class FetchPeerData
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

    def self.call
      new.call
    end

    def call
      SERVERS.flat_map do |host|
        raw_data = `curl -s #{host}/comms/peers`
        data = JSON.parse(raw_data)

        data['peers'] if data['ok']
      end.compact.to_json
    end
  end
end
