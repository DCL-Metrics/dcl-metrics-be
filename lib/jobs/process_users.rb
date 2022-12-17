module Jobs
  class ProcessUsers < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      addresses = FAT_BOY_DATABASE[
        "select distinct address from data_points where date = '#{date}'"
      ].all.flat_map(&:values)

      addresses.each_slice(40) do |address_batch|
        user_data = Adapters::Dcl::UserProfiles.call(addresses: address_batch)

        address_batch.each do |address|
          next if address.nil?
          user = user_data.detect { |x| address == x[:address] } || {}

          # address, date, guest, name, avatar_url
          Jobs::ProcessUser.perform_async(
            address,
            date,
            user.fetch(:guest) { true },
            user[:name],
            user[:avatar_url]
          )
        end
      end
    end
  end
end
