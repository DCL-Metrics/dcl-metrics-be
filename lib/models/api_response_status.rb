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
  end
end
