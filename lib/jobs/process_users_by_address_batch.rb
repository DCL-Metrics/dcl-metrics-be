module Jobs
  class ProcessUsersByAddressBatch < Job
    sidekiq_options queue: 'processing'

    # only_create: no updates are done (i don't want to update last_seen in some cases)
    def perform(addresses, datestamp, only_create = false)
      user_data = Adapters::Dcl::UserProfiles.call(addresses: addresses)

      addresses.each do |address|
        next if address.nil?
        user = user_data.detect { |x| address == x[:address] } || {}

        # address, date, guest, name, avatar_url, only_create
        Jobs::ProcessUser.perform_async(
          address,
          datestamp,
          user.fetch(:guest) { true },
          user[:name],
          user[:avatar_url],
          only_create
        )
      end
    end
  end
end
