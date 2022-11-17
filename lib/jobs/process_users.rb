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
          user = user_data.detect { |x| address == x[:address] } || {}

          # address, date, guest, avatar_url, name
          Jobs::ProcessUser.perform_async(
            address,
            date,
            user.to_json
          )
        end
      end
    end
  end
end
