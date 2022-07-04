###  NOTE: data starts on 10 april 2022
module Services
  class DailyTrafficCalculator
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @snapshot_ids= DATABASE_CONNECTION[
        "select id from peers_dump where created_at :: date = '#{date}'"
      ].all.flat_map(&:values)
    end

    def call
      snapshot_ids.each do |snapshot_id|
        Jobs::ProcessSnapshot.perform_async(snapshot_id)
      end
    end

    private
    attr_reader :snapshot_ids
  end
end

### Stats
# start: 14:56:30
# end: 15:14:19
# duration: ~18 minutes
#
# created: 752_982 models

### Notes
# addresses = DATABASE_CONNECTION["select distinct address from data_points"]
# unique_visitors = addresses.count
# # => ~20k
#
# parcels = DATABASE_CONNECTION["select distinct coordinates from data_points"]
# parcels_visited = parcels.count
# # => ~6k
#
# avg_traffic_per_parcel = unique_visitors / parcels_visited.to_f
#
# # limit 11 in case one is nil
# timespent * SAMPLE_FREQUENCY # 2.5
# top_users = DATABASE_CONNECTION[
#   "SELECT address, COUNT(address) AS time_spent
#   FROM data_points
#   GROUP BY Address
#   ORDER BY time_spent DESC
#   LIMIT 11"
# ]
#
# # limit 11 in case one is nil
# top_parcels = DATABASE_CONNECTION[
#   "SELECT coordinates, COUNT(DISTINCT address) AS unique_visits
#   FROM data_points
#   GROUP BY coordinates
#   ORDER BY unique_visits DESC
#   LIMIT 11"
# ]
#
# visits_per_coordinate_for_address = DATABASE_CONNECTION[
#   "select distinct coordinates, count(coordinates)
#   from data_points
#   where address = '0x7bef3c8be41af128f573732e5f001285c603edd7'
#   group by coordinates
#   LIMIT 10"
# ]

