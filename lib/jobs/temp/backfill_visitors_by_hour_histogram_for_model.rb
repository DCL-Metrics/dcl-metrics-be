module Jobs
  module Temp
    class BackfillVisitorsByHourHistogramForModel < Job
      sidekiq_options queue: 'processing'

      def perform(id)
        model = Models::DailySceneStats[id]
        scene_traffic = Models::ParcelTraffic.where(
          coordinates: model.coordinates.split(';'),
          date: model.date
        )

        return if scene_traffic.empty?

        visitors_by_hour_histogram = scene_traffic.
          flat_map { |pt| JSON.parse(pt.histogram_json) }.
          group_by { |h| h['hour'] }.
          map do |timestamp, data|
            hour = timestamp.split[1].split(':').first
            max_count = data.max_by { |d| d['count'] }['count']
            [hour, max_count]
          end.to_h

        return if visitors_by_hour_histogram.empty?

        model.update(visitors_by_hour_histogram_json: visitors_by_hour_histogram.to_json)
        nil
      end
    end
  end
end
