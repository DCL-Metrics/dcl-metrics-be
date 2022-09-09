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
      response = Faraday.get(url, params)

      print "[#{response.status}] '#{url}'\n"
      # TODO: save response codes per day per url
      return Failure('request was not successful') unless response.status == 200

      begin
        data = JSON.parse(response.body)
      rescue JSON::ParserError => e
        Sentry.capture_exception(e) if defined?(Sentry)

        print "parser error when fetching from '#{url}'\n"
        # TODO: tally parser errors per day per url
        return Failure('malformed json response')
      end

      Success(data)
    end

    private
    attr_reader :url, :params
  end
end
