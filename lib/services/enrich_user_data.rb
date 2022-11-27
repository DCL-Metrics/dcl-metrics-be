# NOTE: expects data as a hash with an address key

# TODO: this should be more like ~serialize_user and take a single address
module Services
  class EnrichUserData
    def self.call(users:)
      new(users).call
    end

    def initialize(users)
      @users = users
    end

    def call
      users.map do |user|
        u = user_data.detect { |ud| ud.address == user[:address] } || null_user

        user[:avatar_url] = u.avatar_url
        user[:guest_user] = u.guest?
        user[:name] = u.name
        user[:verified_user] = u.verified?
        user
      end
    end

    private
    attr_reader :users

    def user_data
      @user_data ||= Models::User.where(address: addresses)
    end

    def addresses
      @addresses ||= users.map { |row| row[:address] }.uniq
    end

    def null_user
      @null_user ||= Models::User.new(guest: true)
    end
  end
end
