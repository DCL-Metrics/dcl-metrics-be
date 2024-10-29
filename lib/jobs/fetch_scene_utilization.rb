module Jobs
  class FetchSceneUtilization < Job
    sidekiq_options queue: 'processing', retry: false

    PARTITION = 4000

    def perform
      Models::Parcel.
        order(:utilization_last_checked_at).
        first(PARTITION).
        each do |parcel|
          Jobs::SaveSceneUtilization.perform_async(parcel.x, parcel.y)
        end
    end
  end
end
