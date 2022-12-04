module Serializers
  class Parcels
    def self.serialize(parcels, include_heat_map_data: false)
      new(parcels, include_heat_map_data).call
    end

    def initialize(parcels, include_heat_map_data)
      @parcels = parcels
      @include_heat_map_data = include_heat_map_data
    end

    def call
      @result = parcels.map do |parcel|
        {
          date: parcel.date.to_s,
          coordinates: parcel.coordinates,
          deploy_count: parcel.deploy_count,
          max_concurrent_users: parcel.max_concurrent_users,
          visitors: parcel.unique_visitors,
          avg_time_spent: parcel.avg_time_spent,
          avg_time_spent_afk: parcel.avg_time_spent_afk,
          logins: parcel.logins,
          logouts: parcel.logouts,
          scene: serialize_scene(parcel.scene_cid)
        }
      end

      return @result unless include_heat_map_data

      inject_heat_map_data
      @result
    end

    private
    attr_reader :parcels, :include_heat_map_data

    def inject_heat_map_data
      @result.each do |r|
        r.merge!(
          visitor_intensity: calculate_intensity(:visitors, r),
          avg_time_spent_intensity: calculate_intensity(:avg_time_spent, r),
          avg_time_spent_afk_intensity: calculate_intensity(:avg_time_spent_afk, r),
          login_intensity: calculate_intensity(:logins, r),
          logout_intensity: calculate_intensity(:logouts, r),
          max_concurrent_user_intensity: calculate_intensity(:max_concurrent_users, r)
        )
      end
    end

    def calculate_intensity(attribute, data)
      return 1 if data[attribute].zero?

      intensity = ((data[attribute] / max_values[attribute].to_f) * 100).round
      return 1 if intensity.zero?

      intensity
    end

    def max_values
      @max_values ||= {
        visitors: max_value_for(:visitors),
        avg_time_spent: max_value_for(:avg_time_spent),
        avg_time_spent_afk: max_value_for(:avg_time_spent_afk),
        logins: max_value_for(:logins),
        logouts: max_value_for(:logouts),
        max_concurrent_users: max_value_for(:max_concurrent_users),
        deploy_count: max_value_for(:deploy_count)
      }
    end

    def max_value_for(attribute)
      @result.max_by { |x| x[attribute] }[attribute]
    end

    def serialize_scene(scene_cid)
      return if scene_cid.nil?

      scene = Models::Scene.find(cid: scene_cid)

      {
        cid: scene.cid,
        last_deployed_at: scene.first_seen_at,
        name: scene.name,
        parcels: scene.parcels
        # map_url: scene.map_url # TODO: ask if this is wanted
      }
    end
  end
end
