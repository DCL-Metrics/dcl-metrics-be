module Jobs
  class ProcessUsers < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      # NOTE: this is preferable but it isn't stable atm
      # addresses = fetch_addresses(date)

      addresses = FAT_BOY_DATABASE[
        "select distinct address from data_points where date = '#{date}'"
      ].all.flat_map(&:values)

      addresses.each_slice(40) do |address_batch|
        user_data = Adapters::Dcl::UserProfiles.call(addresses: address_batch)

        address_batch.each do |address|
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

    private

    def fetch_addresses(date)
      Adapters::AtlasCorp::DailyUsers.call(date: date)[:addresses]
    end
  end
end
