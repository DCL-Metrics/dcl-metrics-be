module Services
  class FetchDclUserData
    URL = 'https://peer-ec1.decentraland.org/lambdas/profiles'

    def self.call(addresses:)
      new(addresses).call
    end

    def initialize(addresses)
      @addresses = addresses.uniq
      @users = []
    end

    # TODO: this probably makes more sense as a job that runs once an hour or so
    # and calls update_or_create on all users in the last hour - but users need
    # to be created before that happens
    def call
      # TODO: after users have been added
      # find_known_users
      create_users_from_unknown_addresses
      return users if all_data_fetched?

      # give it another try for good measure
      remaining_addresses.each { |address| create_users_from_unknown_addresses([address]) }
      users
    end

    private
    attr_reader :addresses
    attr_accessor :users

    def all_data_fetched?
      addresses.count == users.count
    end

    def remaining_addresses
      addresses - users.map { |u| u[:address] }
    end

    # def find_known_users
    #   Models::Users.where(address: remaining_addresses).each do |user|
    #     users.push({
    #       address: user.address,
    #       avatar_url: user.avatar_url,
    #       guest_user: user.guest_user?,
    #       name: user.name,
    #       verified_user: user.verified_user?
    #     })
    #   end
    # end

    def create_users_from_unknown_addresses
      remaining_addresses.each_slice(40) do |batch|
        # TODO: move to adapater
        # get data from url
        # if there is only one element in the array the request needs
        # to be in a different format for whatever reason :shrug:
        if batch.count == 1
          request = `curl -s "#{URL}?id=#{batch[0]}"`
        else
          ids = batch.map { |x| "id=#{x}" }.join('&')
          request = `curl -s -G #{URL} -d "query=#{ids}"`
        end

        user_data = JSON.parse(request).compact

        user_data.each do |data|
          next if data.nil?
          next if data.empty?
          user = data['avatars'][0]

          users.push({
            address: user['userId'],
            avatar_url: user['avatar']['snapshots']['face256'],
            guest_user: !user['hasConnectedWeb3'],
            name: user['name'],
            verified_user: user['hasClaimedName']
          })
        end
      end
    end
  end
end
