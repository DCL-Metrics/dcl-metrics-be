module Jobs
  class CleanUpTransitoryData < Job
    def perform
      DATABASE_CONNECTION[:data_points].truncate
      DATABASE_CONNECTION[:user_activities].truncate

      nil
    end
  end
end
