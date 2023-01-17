module Adapters
  class Base
    include Dry::Monads[:result]

    def self.get(url, params = {})
      new(url, params).get
    end

    def initialize(url, params)
      @url = url
      @params = params
    end

    def get
      begin
        response = Faraday.get(url, params)

        Services::RequestLogger.call(status: response.status, url: url, params: params)
        return Failure('request was not successful') unless response.status == 200

        data = JSON.parse(response.body)
      rescue JSON::ParserError, Faraday::ConnectionFailed => e
        Services::RequestLogger.call(status: 500, url: url, params: params)
        print "error when fetching from '#{url}'\n"
        return Failure(e.message)
      end

      Success(data)
    end

    private
    attr_reader :url, :params
  end
end
