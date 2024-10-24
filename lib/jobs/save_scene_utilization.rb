module Jobs
  class SaveSceneUtilization < Job
    sidekiq_options queue: 'processing'

    WebError = Class.new(::StandardError)

    def perform(x, y, last_update_at, owner)
      url = "https://places.decentraland.org/api/places?positions=#{x},#{y}"
      place_data = Adapters::Base.get(url)
      raise WebError unless place_data.success?

      Models::Parcel.update_or_create(x: x, y: y) do |p|
        p.active_deploy = !place_data.success['data'].empty?
        p.owner = owner
        p.last_update_at = Time.at(last_update_at / 1000)
      end

      nil
    end
  end
end
