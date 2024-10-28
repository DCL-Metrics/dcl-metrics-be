module Jobs
  class SaveSceneUtilization < Job
    sidekiq_options queue: 'processing'

    def perform(x, y, last_update_at = nil, owner = nil, count = 1)
      return if count > 5

      parcel = Models::Parcel.find(x: x, y: y)
      # don't check more than once a day
      return if parcel.utilization_last_checked_at > Time.now.utc - 60 * 60 * 24

      url = "https://places.decentraland.org/api/places?positions=#{x},#{y}"
      place_data = Adapters::Base.get(url)

      if place_data.success?
        Models::Parcel.update_or_create(x: x, y: y) do |p|
          p.active_deploy = !place_data.success['data'].empty?
          p.owner = owner unless owner.nil?
          p.last_update_at = Time.at(last_update_at / 1000) unless last_update_at.nil?
          p.utilization_last_checked_at = Time.now.utc
        end
      else
        p '##################################################'
        p '##################################################'
        p place_data
        p '##################################################'
        p '##################################################'
        sleep 0.5
        Jobs::SaveSceneUtilization.perform_async(x, y, last_update_at, owner, count + 1)
      end

      nil
    end
  end
end
