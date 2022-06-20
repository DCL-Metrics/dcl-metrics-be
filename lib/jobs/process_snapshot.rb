module Jobs
  class ProcessSnapshot < Job
    def perform(snapshot_id)
      snapshot = Models::PeersDump[snapshot_id]
      timestamp = snapshot.created_at

      snapshot.data.each do |visit|
        Models::DataPoint.create(
          address: visit['address'],
          coordinates: visit['parcel'],
          date: timestamp.to_date,
          peer_id: visit['id'],
          position: visit['position']&.map { |x| x.round(2) },
          timestamp: timestamp
        )
      end
    end
  end
end
