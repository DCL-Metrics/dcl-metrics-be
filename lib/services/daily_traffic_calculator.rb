###  NOTE: data starts on 10 april 2022
module Services
  class DailyTrafficCalculator
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @snapshot_ids= DATABASE_CONNECTION[
        "select id from peers_dump where created_at :: date = '#{date}'"
      ].all.flat_map(&:values).compact
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

