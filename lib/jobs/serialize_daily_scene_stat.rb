module Jobs
  class SerializeDailySceneStat < Job
    sidekiq_options queue: 'processing'

    def perform(id)
      model = Models::DailySceneStats[id]
      data_json = Serializers::Scenes.serialize([model]).to_json

      Models::SerializedDailySceneStats.create(
        date: model.date,
        name: model.name,
        coordinates: model.coordinates,
        data_json: data_json
      )
    end
  end
end
