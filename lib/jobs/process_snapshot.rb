module Jobs
  class ProcessSnapshot < Job
    sidekiq_options queue: 'processing'

    def perform(snapshot_id)
      snapshot = Models::PeersDump[snapshot_id]
      timestamp = snapshot.created_at

      # TODO: if snapshot data were NDJ format
      # snapshot.data_ndj.split("\n").each do |data|
      #   visit = JSON.parse(data)
      #   ...
      # end

      snapshot.data.each do |visit|
        # NOTE: it seems like sometimes this has brackets around it
        # but i can't reliably reproduce it
        coordinates = visit['parcel']&.join(',')
        position = visit['position']&.map(&:round)&.join(',')

        next if coordinates.nil?
        next if position.nil?

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
