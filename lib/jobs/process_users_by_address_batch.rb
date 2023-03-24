module Jobs
  class ProcessUsersByAddressBatch < Job
    sidekiq_options queue: 'processing'

    def perform(addresses, datestamp, first_seen_in_dao = false)
      user_data = Adapters::Dcl::UserProfiles.call(addresses: addresses)

      addresses.each do |address|
        next if address.nil?
        user = user_data.detect { |x| address == x[:address] } || {}

        # address, date, guest, name, avatar_url, first_seen_in_dao
        Jobs::ProcessUser.perform_async(
          address,
          datestamp,
          user.fetch(:guest) { true },
          user[:name],
          user[:avatar_url],
          first_seen_in_dao
        )
      end
    end
  end
end
