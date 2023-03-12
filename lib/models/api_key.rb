# primary_key :id
#
# String  :key,               null: false
# Jsonb   :permissions_json,  default: "{}"
# Time    :expires_at,        null: false
#
# Time    :created_at,  null: false
# Time    :updated_at,  null: false
#
# add_index :api_keys, :key, unique: true

module Models
  class ApiKey < Sequel::Model(FAT_BOY_DATABASE[:api_keys])
    def expired?
      expires_at < Time.now.utc
    end

    # currently there are these permissions:
    # global
    # scenes
    # parcels
    # peer_status
    # reports
    def permitted?(endpoint)
      return true if permissions['all']

      endpoint_key = endpoint.split('/')[1]
      return true if permissions[endpoint_key]

      false
    end

    def permissions
      @permissions ||= JSON.parse(permissions_json)
    end
  end
end
