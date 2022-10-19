# NOTE: expects data as a hash with an address key

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
        api_data = user_data.detect { |ud| ud[:address] == user[:address] } || {}

        user[:avatar_url] = api_data[:avatar_url]
        user[:guest_user] = api_data[:guest_user]
        user[:name] = api_data[:name]
        user[:verified_user] = api_data[:verified_user]
        user
      end
    end

    private
    attr_reader :users

    def user_data
      @user_data ||= Services::FetchDclUserData.call(addresses: addresses)
    end

    def addresses
      @addresses ||= users.map { |row| row[:address] }.uniq
    end
  end
end
