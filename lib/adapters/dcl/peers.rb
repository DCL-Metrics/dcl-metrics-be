module Adapters
  module Dcl
    class Peers
      # NOTE: 2024-01-22
      # commented servers have no archipelago service
      # so they're just always down.
      SERVERS = [
        # "https://peer-ec1.decentraland.org",
        # "https://peer-ec2.decentraland.org",
        # "https://peer-wc1.decentraland.org",
        # "https://peer-eu1.decentraland.org",
        # "https://peer-ap1.decentraland.org",
        # "https://interconnected.online",
        # "https://peer.decentral.io",
        # "https://peer.melonwave.com",
        "https://peer.kyllian.me",
        # "https://peer.uadevops.com",
        # "https://peer.dclnodes.io"
        "https://archipelago-ea-stats.decentraland.org/peers"
      ]

      def self.fetch_snapshot
        data = new('comms/peers').call

        data.flat_map { |d| d['peers'] if d['ok'] }
      end

      def self.fetch_stats
        data = new('stats/parcels').call

        data.flat_map { |d| d['parcels'] }
      end

      def initialize(endpoint)
        @endpoint = endpoint
      end

      def call
        SERVERS.flat_map do |host|
          response = Adapters::Base.get("#{host}/#{endpoint}")
          next if response.failure?

          data = response.success

          if data.class == Array
            p "data error. skipping data from host: #{host}"
            next
          end

          data if data.class == Hash
        end.compact
      end

      private
      attr_reader :endpoint
    end
  end
end
