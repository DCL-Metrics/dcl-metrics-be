###  NOTE: data starts on 10 april 2022
module Services
  class DailyTrafficCalculator
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @snapshot_ids= DATABASE_CONNECTION[
        "select ids from peers_dump where created_at :: date = '#{date}'"
      ].all.flat_map(&:values)
    end

    def call
      snapshot_ids.each do |snapshot_id|
        Jobs::ProcessSnapshot.perform_later(snapshot_id)
      end
    end

    private
    attr_reader :snapshot_ids
  end
end
