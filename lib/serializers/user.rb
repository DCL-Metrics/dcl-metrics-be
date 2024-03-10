module Serializers
  class User
    def self.serialize(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      {
        address: user.address,
        name: user.name,
        avatar_url: user.avatar_url,
        first_seen: user.first_seen.to_s,
        last_seen: user.last_seen.to_s,
        guest: user.guest?,
        verified: user.verified?,
        dao_member: user.dao_member?
      }
    end

    private
    attr_reader :user
  end
end
