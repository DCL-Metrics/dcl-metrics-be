module Jobs
  class ProcessUsersInSnapshot < Job
    sidekiq_options queue: 'processing'

    def perform(snapshot_id)
      snapshot = Models::PeersDump[snapshot_id]
      datestamp = snapshot.created_at.to_date.to_s
      addresses = snapshot.data.flat_map { |x| x['address'] }.uniq.compact
      already_processed = Models::User.
        select(:address).
        where(address: addresses, last_seen: snapshot.created_at.to_date).
        flat_map { |x| x.values.values }

      processable = addresses - already_processed
      print "#{self.class.name}: processing #{processable.count} users\n"

      processable.each_slice(40) do |address_batch|
        Jobs::ProcessUsersByAddressBatch.perform_async(address_batch, datestamp)
      end
    end
  end
end
