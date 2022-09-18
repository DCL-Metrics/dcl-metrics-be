module Services
  class DailySceneStatsBuilder
    def self.call(date:, unique_users:)
      new(date, unique_users).call
    end

    def initialize(date, unique_users)
      @date = date
      @unique_users = unique_users
    end

    def call
      Models::DailySceneStats.where(date: date).delete

      Models::Scene.collect(cids).each do |group, data|
        # name, coordiantes, cids, unique_users
        Jobs::ProcessDailySceneStats.
          perform_async(date, group.first, group.last, data.flat_map(&:cid), unique_users)
      end
    end

    private
    attr_reader :date, :unique_users

    def cids
      @cids ||= DATABASE_CONNECTION[
        "select distinct scene_cid from peer_stats where date = '#{date}'"
      ].all.flat_map(&:values).compact
    end
  end
end
