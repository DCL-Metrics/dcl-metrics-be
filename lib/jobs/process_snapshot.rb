module Jobs
  class ProcessSnapshot < Job
    def perform(snapshot_id)
      snapshot = Models::PeersDump[snapshot_id]
      data = JSON.parse(snapshot.data)
      timestamp = data.created_at

      data.each do |visit|
        DataPoint.create(
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
