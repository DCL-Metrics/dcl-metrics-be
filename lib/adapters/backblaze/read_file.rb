module Adapters
  module Backblaze
    class ReadFile
      AuthenticationError = Class.new(::StandardError)
      B2_AUTH_URL = 'https://api.backblazeb2.com/b2api/v2/b2_authorize_account'

      def self.call(bucket:, filename:)
        new(bucket, filename).call
      end

      def initialize(bucket, filename)
        @bucket = bucket
        @filename = filename
      end

      def call
        # create connection for reading
        conn = Faraday.new(B2_AUTH_URL) do |conn|
          conn.request :authorization,
            :basic,
            ENV['B2_APPLICATION_KEY_FOR_READING_ID'],
            ENV['B2_APPLICATION_KEY_FOR_READING']
        end

        response = conn.get
        return response unless response.success?

        auth = JSON.parse(response.body)
        download_url = "#{auth['downloadUrl']}/file/#{@bucket}/#{@filename}"

        Faraday.get(download_url) do |request|
          request.headers['Authorization'] = auth['authorizationToken']
        end
      end
    end
  end
end
