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
        response = Adapters::Base.post(URL, { ids: addresses })
        return [] if response.failure?

        response.success.compact.map do |user_data|
          user = user_data['avatars'][0]
          verified_user = user['hasClaimedName']

          # NOTE: guest user has a triple bang - force boolean and then invert it
          {
            address: user['userId'],
            avatar_url: user['avatar']['snapshots']['face256'],
            guest: verified_user ? false : !!!user['hasConnectedWeb3'],
            name: user['name'],
            verified: verified_user
          }
        end
      end

      private
      attr_reader :addresses
    end
  end
end
