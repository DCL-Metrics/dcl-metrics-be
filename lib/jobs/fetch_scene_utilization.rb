module Jobs
  class FetchSceneUtilization < Job
    sidekiq_options queue: 'processing', retry: false

    PARTITION = 4000

    def perform
      return

      Models::Parcel.
        order(:utilization_last_checked_at).
        first(PARTITION).
        each do |parcel|
          sleep 0.3
          Jobs::SaveSceneUtilization.perform_async(parcel.x, parcel.y)
        end

      nil
    end
  end
end
