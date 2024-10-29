module Jobs
  class SaveSceneUtilization < Job
    sidekiq_options queue: 'processing'

    def perform(x, y, count = 1)
      return if count > 3

      parcel = Models::Parcel.find(x: x, y: y)

      # non-existant / out-of-bounds parcel
      return if parcel.nil?

      # don't check more than once a day
      return if parcel.utilization_last_checked_at > Time.now.utc - 60 * 60 * 24

      # rate limiting for this endpoint is very aggressive
      # if we get to this point, wait a moment
      sleep 1

      url = "https://places.decentraland.org/api/places?positions=#{x},#{y}"
      place_data = Adapters::Base.get(url)

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

        # maybe TODO: if place_data.failure.last(3) == 429
        #         retry_in between 45s - 60s
        # sleep 2 * count * Random.rand(30..60)

        sleep 2 * count
        Jobs::SaveSceneUtilization.perform_async(x, y, count + 1)
      end
    end
  end
end
