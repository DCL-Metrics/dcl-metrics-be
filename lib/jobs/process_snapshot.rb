module Jobs
  class ProcessSnapshot < Job
    def perform(snapshot_id)
      snapshot = Models::PeersDump[snapshot_id]
      timestamp = snapshot.created_at

      snapshot.data.each do |visit|
        coordinates = visit['parcel']&.join(',')
        position = visit['position']&.map { |x| x.round(2) }&.join(',')

        Models::DataPoint.create(
          address: visit['address'],
          coordinates: coordinates,
          date: timestamp.to_date,
          peer_id: visit['id'],
          position: position,
          timestamp: timestamp
        )
      end
    end
  end
end
