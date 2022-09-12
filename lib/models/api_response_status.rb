# primary_key :id
#
# Date    :date,            null: false
# String  :url,             null: false
# Jsonb   :responses_json,  null: false
# Integer :success_count,   null: false, default: 0
# Integer :failure_count,   null: false, default: 0
#
# Time    :created_at,      null: false
#
# add_index :api_response_statuses, [:date]
# add_index :api_response_statuses, [:url]
# add_index :api_response_statuses, [:date, :url], unique: true

module Models
  class ApiResponseStatus < Sequel::Model(:api_response_statuses)
    def self.daily_failure_rate(date)
      where(date: date).
        all.
        select(&:catalyst_stats?).
        map(&:failure_rate).
        any? { |rate| rate >= 5 }
    end

    def failure_rate
      (failure_count / total_count.to_f) * 100
    end

    def total_count
      success_count + failure_count
    end

    def host
      url.sub('https://','').split('/').first
    end

    def endpoint
      url.split('/').last(2).join('/')
    end

    def catalyst_stats?
      ['stats/parcels', 'comms/peers'].include?(endpoint)
    end
  end
end
