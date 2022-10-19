# NOTE: expects data as a hash with an address key

module Services
  class EnrichUserData
    def self.call(data:)
      new(data).call
    end

    def initialize(data)
      @data = data
    end

    def call
      data.each do |d|
        user = user_data.detect { |u| u[:address] == d[:address] }
        next unless user

        d[:avatar_url] = user[:avatar_url]
        d[:guest_user] = user[:guest_user]
        d[:name] = user[:name]
        d[:verified_user] = user[:verified_user]
      end

      # NOTE: useful for debugging
      # data.select { |d| d[:name].nil? }.each do |d|
      #   print "#{self.class.name}: can't find data for address #{d[:address]}\n"
      # end

      data
    end

    private
    attr_reader :data

    def user_data
      @user_data ||= Services::FetchDclUserData.call(addresses: addresses)
    end

    def addresses
      data.map { |row| row[:address] }.uniq
    end
  end
end
