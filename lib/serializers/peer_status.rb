module Serializers
  class PeerStatus
    def self.serialize(api_responses)
      new(api_responses).call
    end

    def initialize(api_responses)
      @api_responses = api_responses
      @result = {}
    end

    def call
      api_responses.group_by(&:endpoint).each do |endpoint, responses|
        result[endpoint] = build_response(responses)
      end

      result
    end

    private
    attr_reader :api_responses, :result

    def build_response(responses)
      responses.map do |response|
        {
          date: response.date.to_s,
          url: response.url,
          host: response.host,
          statuses: response.status_counts,
          failure_count: response.failure_count,
          failure_rate: response.failure_rate,
          success_rate: 100 - response.failure_rate,
          success_count: response.success_count,
          total_count: response.total_count
        }
      end
    end
  end
end
