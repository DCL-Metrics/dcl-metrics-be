module Services
  class RequestLogger
    SUCCESS_RESPONSES = [200, 201]

    def self.call(status:, url:, params:)
      new(status, url, params).call
    end

    def initialize(status, url, params)
      @status = status
      @url = url
      @params = params
    end

    def call
      query = { date: Date.today.to_s, url: url }
      success = SUCCESS_RESPONSES.include?(status) ? true : false

      Models::ApiResponseStatus.update_or_create(query) do |model|
        responses = build_response(model, status)
        model.responses_json = responses.to_json

        model.success_count ||= 0
        model.failure_count ||= 0

        model.success_count += 1 if success
        model.failure_count += 1 if !success
      end
    end

    private
    attr_reader :status, :url, :params

    require 'pry'
    def build_response(model, status)
      data = model.responses_json ? JSON.parse(model.responses_json) : new_response

      data['statuses'][status.to_s] ||= 0
      data['statuses'][status.to_s] += 1

      data['params'][status.to_s] ||= []
      data['params'][status.to_s].push(params.transform_keys(&:to_s))
      data['params'][status.to_s].uniq!

      data
    end

    def new_response
      # when it's parsed the keys are stringified so just make them strings to start
      { 'statuses' => Hash.new(0), 'params' => Hash.new([]) }
    end
  end
end

