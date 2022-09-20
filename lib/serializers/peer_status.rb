module Serializers
  class PeerStatus
    def self.serialize(api_responses)
      new(api_responses).call
    end

    def initialize(api_responses)
      @api_responses = api_responses
    end

    def call
      api_responses.map do |response|
        {
          date: response.date.to_s,
          url: response.url,
          statuses: response.status_counts,
          failure_count: response.failure_count,
          failure_rate: response.failure_rate,
          success_count: response.success_count,
          total_count: response.total_count
        }
      end
    end

    private
    attr_reader :api_responses
  end
end
