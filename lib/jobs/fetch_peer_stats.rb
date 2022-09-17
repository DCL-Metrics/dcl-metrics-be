module Jobs
  class FetchPeerStats < Job
    sidekiq_options queue: 'scraping'

    def perform
      data = Adapters::Dcl::Peers.fetch_stats
      date = Date.today.to_s
      current_time = Time.now.utc

      # format data
      formatted_data = {}
      data.group_by { |d| d['parcel'] }.each do |coordinates_hash, data|
        coordinates = "#{coordinates_hash['x']},#{coordinates_hash['y']}"
        formatted_data[coordinates] = {
          'count' => data.sum { |d| d['peersCount'] },
          'scene_cid' => nil
        }
      end

      # grab scenes
      coordinates = formatted_data.keys
      scenes = Services::FetchSceneData.call(coordinates: coordinates)

      # enrich data with scene cid
      formatted_data.each do |coordinates, data|
        scene = scenes.detect { |s| s[:parcels].include?(coordinates) }
        next if scene.nil? # empty parcel

        data['scene_cid'] = scene[:id]
      end

      # create model
      formatted_data.each do |coordinates, data|
        query = {
          coordinates: coordinates,
          date: date,
          scene_cid: data['scene_cid']
        }

        Models::PeerStats.update_or_create(query) do |ps|
          parcel_data = ps.data_json ? JSON.parse(ps.data_json) : {}
          parcel_data[current_time.to_i] =  data['count']

          ps.data_json = parcel_data.to_json
        end
      end

      # create any unknown scenes
      scenes.each do |scene|
        Models::Scene.find_or_create(cid: scene[:id]) do |s|
          s.name          = scene[:name]
          s.owner         = scene[:owner]
          s.parcels_json  = scene[:parcels].to_json
          s.first_seen_at = current_time
          s.first_seen_on = date
        end
      end
    end
  end
end
