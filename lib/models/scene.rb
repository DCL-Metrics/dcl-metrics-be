# primary_key :id
#
# String  :cid, null: false, unique: true
# String  :scene_disambiguation_uuid
# String  :name
# String  :coordinates
# String  :owner
# Jsonb   :parcels_json, null: false # TODO: remove when coordinates is populated
# Time    :first_seen_at
# Date    :first_seen_on
#
# add_index :scenes, [:cid]

module Models
  class Scene < Sequel::Model
    # group scenes by name and deployed parcels
    # each deploy gets a new CID so multiple CIDs
    # can actually refer to the "same" scene
    def self.collect(cids)
      where(cid: cids).
        reject(&:public_road?).
        group_by { |s| [s.name, s.parcels.sort] }
    end

    def parcels
      JSON.parse(parcels_json)
    end

    def public_road?
      parcels.any? { |parcel| PUBLIC_ROADS.include?(parcel) }
    end
  end
end

# TODO: would be nice to show "recently deployed scenes"
# scenes updated yesterday
# cids = DATABASE_CONNECTION[
#   "select cid
#   from scenes
#   where first_seen_on = '#{Date.today - 1}'"
# ].flat_map(&:values).compact
# scenes = Models::Scenes.collect(cids)
