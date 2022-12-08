module Adapters
  module AtlasCorp
    class Peers
      URL = 'https://dao-data.atlascorp.io/islands-history'

      def self.fetch_snapshot
        new.call
      end


      def call
        response = Adapters::Base.get(URL)
        return {} if response.failure?

        response.
          success['data'].
          flat_map { |data| data['islands'] }.
          flat_map { |island| island['peers'] }
      end

      private
      attr_reader :date
    end
  end
end
