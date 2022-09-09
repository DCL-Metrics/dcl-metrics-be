module Adapters
  module Dcl
    class UserProfiles
      URL = 'https://peer-ec1.decentraland.org/lambdas/profiles'

      def self.call(addresses:)
        new(addresses).call
      end

      def initialize(addresses)
        @addresses = addresses
      end

      def call
        response = Adapters::Base.get(URL, { id: addresses })
        return [] if response.failure?

        response.success.compact
      end

      private
      attr_reader :addresses
    end
  end
end
