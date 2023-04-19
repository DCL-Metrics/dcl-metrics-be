# primary_key :id
#
# String    :address, null: false
# String    :avatar_url
# String    :name
# TrueClass :guest
# Date      :first_seen, null: false
# Date      :last_seen
#
# Time    :created_at,      null: false
# Time    :updated_at,      null: false
#
# add_index :users, :address, unique: true
# add_index :users, :first_seen

module Models
  class User < Sequel::Model(FAT_BOY_DATABASE[:users])
    def nfts
      @nfts ||= Models::UserNfts.find(address: address)
    end

    def dao_activity
      @dao_activity ||= Models::UserDaoActivity.find(address: address)
    end

    def stats
      @stats ||= Models::DailyUserStats.where(address: user.address)
    end

    # TODO: need to move scenes table to fat_boy_db and then can do a join
    # FAT_BOY_DATABASE[
    #   "select t1.scene_cid, t1.duration,
    #           t2.name as name, t2.scene_disambiguation_uuid as uuid
    #   from user_activities t1
    #   left outer join scenes t2 on t1.scene_cid = t2.cid
    #   where t1.address = '#{address}'
    #   and t1.name = 'visit_scene'"
    # ].count
    def top_scenes_visited
      FAT_BOY_DATABASE[
        "select scene_cid, duration from user_activities
        where address = '#{address}'
        and name = 'visit_scene'"
      ].
      all.
      map { |a| [Models::Scene.find(cid: a[:scene_cid]), a[:duration]] }.
      group_by { |scene, duration| scene&.scene_disambiguation_uuid }.
      map do |uuid, data|
        scene_name = data.first.first&.name
        next if scene_name.nil?

        {
          scene_uuid: uuid,
          scene_name: scene_name,
          map_url: map_url(data.first.first&.coordinates),
          duration: data.first.last
        }
      end.
      compact.
      sort_by { |x| x[:duration] }.
      last(20).
      reverse
    end

    # TODO: formatting needs to match daily stats serializers to fit charts / consistency
    def scenes_visited_histogram
      FAT_BOY_DATABASE[
        "select count(id), date_trunc('day', date)::date as date
        from user_activities
        where name = 'visit_scene'
        and address = '#{address}'
        group by date
        order by 2"
      ].all
    end

    # TODO subtract time afk from this calculation
    def time_spent_histogram
      FAT_BOY_DATABASE[
        "select sum(duration) as time_spent, date_trunc('day', date)::date as date
        from user_activities
        where name = 'session'
        and address = '#{address}'
        group by date
        order by 2"
      ].all
    end

    # TODO: should be a global helper
    def map_url(coordinates)
      return "" if coordinates.nil?
      center = coordinates.split(';').first
      selected = coordinates

      "https://api.decentraland.org/v2/map.png?center=#{center}&selected=#{selected}"
    end

    def name
      values[:name] || 'Guest User'
    end

    def guest?
      !!guest
    end

    def verified?
      !!nfts&.owns_dclens
    end

    def dao_member?
      !!dao_activity
    end
  end
end
