# primary_key :id
#
# String  :cid, null: false, unique: true
# String  :scene_disambiguation_uuid
# String  :name
# String  :coordinates
# String  :owner
# Time    :first_seen_at
# Date    :first_seen_on
#
# add_index :scenes, [:cid]

module Models
  class Scene < Sequel::Model(FAT_BOY_DATABASE[:scenes])
    def self.collect(cids)
      where(cid: cids).reject(&:public_road?).group_by(&:scene_disambiguation_uuid)
    end

    def scene_disambiguation
      Models::SceneDisambiguation.find(uuid: scene_disambiguation_uuid)
    end

    # TODO: extract this to helper
    def map_url
      center = coordinates.split(';').first
      selected = coordinates

      "https://api.decentraland.org/v2/map.png?center=#{center}&selected=#{selected}"
    end

    def public_road?
      coordinates.split(';').any? { |parcel| PUBLIC_ROADS.include?(parcel) }
    end
  end
end

# TODO: would be nice to show "recently deployed scenes"
# scenes updated yesterday
# cids = FAT_BOY_DATABASE[
#   "select cid
#   from scenes
#   where first_seen_on = '#{Date.today - 1}'"
# ].flat_map(&:values).compact
# scenes = Models::Scenes.collect(cids)
