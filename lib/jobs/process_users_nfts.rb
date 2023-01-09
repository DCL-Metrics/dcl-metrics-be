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

      first_seen_today = Models::User.
        where(first_seen: Date.today - 1).
        where(guest: false).
        map(&:address)

      addresses_not_recently_updated = Models::UserNfts.stale.map(&:address)

      [
        addresses_not_recently_updated,
        addresses_with_no_nft_model,
        first_seen_today
      ].
      flatten.
      uniq.
      each_slice(1000) do |addresses|
        addresses.each { |address| Jobs::ProcessUserNfts.perform_async(address) }
      end
    end
  end
end
