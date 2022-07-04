module Jobs
  class ProcessSnapshot < Job
    def perform(snapshot_id)
      snapshot = Models::PeersDump[snapshot_id]
      timestamp = snapshot.created_at

      # TODO: if snapshot data were NDJ format
      # snapshot.data_ndj.split("\n").each do |data|
      #   visit = JSON.parse(data)
      #   ...
      # end

      snapshot.data.each do |visit|
        coordinates = visit['parcel']&.join(',')
        position = visit['position']&.map(&:round)&.join(',')

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
