module Jobs
  class ProcessUsersNfts < Job
    sidekiq_options queue: 'processing'

    def perform
      # always perform this on non-guest users where there is no nfts model yet
      addresses_with_no_nft_model = FAT_BOY_DATABASE[
        "select t1.address
        from users t1
        left join user_nfts t2 on t1.address = t2.address
        where t2.id is null and t1.guest = false"
      ].all.flat_map(&:values)

      # TODO: later, run this for users where first_seen = Date.today

      addresses_not_recently_updated = Models::UserNfts.stale.map(&:address)

      [
        addresses_with_no_nft_model,
        addresses_not_recently_updated
      ].
      flatten.
      each_slice(1000) do |addresses|
        addresses.each { |u| Jobs::ProcessUserNfts.perform_async(address: u.address) }
      end
    end
  end
end
