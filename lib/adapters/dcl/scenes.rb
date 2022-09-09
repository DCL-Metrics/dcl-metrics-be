module Adapters
  module Dcl
    class Scenes
      URL = 'https://peer.decentraland.org/content/entities/scene'

      def self.call(coordinates:)
        new(coordinates).call
      end

      def initialize(coordinates)
        @coordinates = coordinates
      end

      def call
        response = Adapters::Base.get(URL, { pointer: coordinates })
        return [] if response.failure?

        response.success.compact
      end

      private
      attr_reader :coordinates
    end
  end
end
