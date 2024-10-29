module Jobs
  class SaveSceneUtilization < Job
    sidekiq_options queue: 'processing', retry: false

    def perform(x, y)
      parcel = Models::Parcel.find(x: x, y: y)

      # non-existant / out-of-bounds parcel
      return if parcel.nil?

      # don't check more than once a day
      return if parcel.utilization_last_checked_at > Time.now.utc - 60 * 60 * 24

      # rate limiting for this endpoint is very aggressive
      # if we get to this point, wait a moment
      sleep 1

      url = 'https://places.decentraland.org/api/places'
      place_data = Adapters::Base.get(url, { positions: "#{x},#{y}" })

      if place_data.success?
        update_params = { utilization_last_checked_at: Time.now.utc }

        if place_data.success['data'].empty?
          update_params[:active_deploy] = false
          parcel.update(update_params)
        else
          place_data.success['data'][0]['positions'].each do |coordinates|
            x,y = coordinates.split(',')
            parcel = Models::Parcel.find(x: x, y: y)

            update_params[:active_deploy] = true
            parcel.update(update_params)
          end
        end
      else
        p '##################################################'
        p '##################################################'
        p [x, y] => place_data.failure
        p '##################################################'
        p '##################################################'
      end
    end
  end
end
