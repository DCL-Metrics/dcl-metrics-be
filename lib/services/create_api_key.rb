module Services
  class CreateApiKey
    def self.call(permissions:, duration_days:)
      new(permissions, duration_days).call
    end

    def initialize(permissions, duration_days)
      @permissions = permissions
      @duration_days = duration_days
    end

    def call
      Models::ApiKey.create(
        key: SecureRandom.uuid,
        expires_at: Date.today + duration_days,
        permissions_json: build_permissions.to_json
      )
    end

    private
    attr_reader :permissions, :duration_days

    def build_permissions
      {
        all: permissions[:all],
        global: permissions[:all] || permissions[:global],
        scenes: permissions[:all] || permissions[:scenes],
        parcels: permissions[:all] || permissions[:parcels],
        peer_status: permissions[:all] || permissions[:status],
        reports: permissions[:all] || permissions[:reports]
      }
    end
  end
end
