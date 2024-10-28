module Adapters
  class Base
    include Dry::Monads[:result]

    JSON_FORMAT = 'json'
    CSV_FORMAT = 'csv'

    def self.get(url, params = {}, headers = {})
      new(url, params, headers).get
    end

    def self.post(url, body = {}, headers = {})
      new(url, body, headers.merge('content-type': 'application/json')).post
    end

    def initialize(url, params, headers)
      @url = url
      @params = params
      @headers = headers
      @format = params.fetch(:response_format) { JSON_FORMAT }
    end

    def get
      begin
        response = Faraday.get(url, params, headers)

        Services::RequestLogger.call(status: response.status, url: url, params: params)

        # TEMP
        p response if response.status != 200

        return Failure('request was not successful') unless response.status == 200

        data = case format
               when JSON_FORMAT
                 JSON.parse(response.body)
               when CSV_FORMAT
                 CSV.parse(response.body)
               else
                 response.body
               end
      rescue JSON::ParserError, Faraday::ConnectionFailed => e
        Services::RequestLogger.call(status: 500, url: url, params: params)
        print "error when fetching from '#{url}'\n"
        return Failure(e.message)
      end

      Success(data)
    end

    def post
      begin
        response = Faraday.post(url, params.to_json, headers)

        Services::RequestLogger.call(status: response.status, url: url, params: params)
        return Failure('request was not successful') unless response.status == 200

        data = case format
               when JSON_FORMAT
                 JSON.parse(response.body)
               when CSV_FORMAT
                 CSV.parse(response.body)
               else
                 response.body
               end
      rescue JSON::ParserError, Faraday::ConnectionFailed => e
        Services::RequestLogger.call(status: 500, url: url, params: params)
        print "error when fetching from '#{url}'\n"
        return Failure(e.message)
      end

      Success(data)
    end

    private
    attr_reader :url, :params, :headers, :format
  end
end
