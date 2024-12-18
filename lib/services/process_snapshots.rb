###  NOTE: data starts on 10 april 2022
module Services
  class ProcessSnapshots
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @snapshot_ids= FAT_BOY_DATABASE[
        "select id from peers_dump where created_at :: date = '#{date}'"
      ].all.flat_map(&:values).compact
    end

    def call
      Models::DataPoint.where(date: date).each(&:delete)

      snapshot_ids.each do |snapshot_id|
        Jobs::ProcessSnapshot.perform_async(snapshot_id)
      end
    end

    private
    attr_reader :snapshot_ids
  end
end
