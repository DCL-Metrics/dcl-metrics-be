# primary_key :id
#
# String  :key,               null: false
# String  :endpoint,          null: false
# String  :ip_address,        null: false
# Jsonb   :query_params_json, default: "{}"
# Integer :response,          null: false
#
# Time    :created_at,        null: false
#
# add_index :api_key_access_logs, :key
# add_index :api_key_access_logs, :endpoint
# add_index :api_key_access_logs, :ip_address

module Models
  class ApiKeyAccessLog < Sequel::Model(FAT_BOY_DATABASE[:api_key_access_logs])
    def query_params
      JSON.parse(query_params_json)
    end
  end
end
