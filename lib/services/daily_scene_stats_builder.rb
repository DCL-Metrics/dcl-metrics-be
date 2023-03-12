module Services
  class DailySceneStatsBuilder
    def self.call(date:)
      new(date).call
    end

    def initialize(date)
      @date = date
    end

    def call
      Models::DailySceneStats.where(date: date).delete

      Models::Scene.collect(cids).each do |uuid, scenes|
        # date, scene_disambiguation_uuid, cids, total_unique_users
        Jobs::ProcessDailySceneStats.perform_async(
          date.to_s,
          uuid,
          scenes.flat_map(&:cid),
          user_count
        )
      end
    end

    private
    attr_reader :date

    def cids
      FAT_BOY_DATABASE[
        "select distinct scene_cid from data_points where date = '#{date}'"
      ].all.flat_map(&:values).compact
    end

    def user_count
      FAT_BOY_DATABASE[
        "select distinct address from data_points where date = '#{date}'"
      ].count
    end
  end
end
