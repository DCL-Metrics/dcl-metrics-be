module Jobs
  class SaveSceneUtilization < Job
    sidekiq_options queue: 'processing'

    def perform(x, y, last_update_at = nil, owner = nil, count = 1)
      return if count > 3

      parcel = Models::Parcel.find_or_create(x: x, y: y)
      # don't check more than once a day
      return if parcel.utilization_last_checked_at > Time.now.utc - 60 * 60 * 24

      url = "https://places.decentraland.org/api/places?positions=#{x},#{y}"
      place_data = Adapters::Base.get(url)

      if place_data.success?
        update_params = {
          active_deploy: !place_data.success['data'].empty?,
          utilization_last_checked_at: Time.now.utc
        }

        update_params[:owner] = owner unless owner.nil?
        update_params[:last_update_at] = Time.at(last_update_at / 1000) unless last_update_at.nil?

        parcel.update(update_params)
      else
        p '##################################################'
        p '##################################################'
        p [x, y] => place_data.failure
        p '##################################################'
        p '##################################################'

        sleep 2
        Jobs::SaveSceneUtilization.perform_async(x, y, last_update_at, owner, count + 1)
      end

      nil
    end
  end
end
