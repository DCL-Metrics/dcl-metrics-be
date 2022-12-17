module Jobs
  class SerializeDailyParcelStats < Job
    sidekiq_options queue: 'processing'

    def perform(date)
      Models::SerializedDailyParcelStats.where(date: date).delete

      data = Serializers::Parcels.
        serialize(Models::DailyParcelStats.where(date: date), include_heat_map_data: true).
        to_json

      Models::SerializedDailyParcelStats.create(date: date, data_json: data)
    end
  end
end
