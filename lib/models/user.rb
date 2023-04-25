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

    def top_scenes_visited
      FAT_BOY_DATABASE[
        "select SUM(t1.duration) as duration,
                t2.name as name, t2.scene_disambiguation_uuid as uuid
        from user_activities t1
        left outer join scenes t2 on t1.scene_cid = t2.cid
        where t1.address = '#{address}'
        and t1.name = 'visit_scene' and t2.name is not null
        group by
          t2.scene_disambiguation_uuid,
          t2.name
        order by duration DESC
        LIMIT 20"
      ].all
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
