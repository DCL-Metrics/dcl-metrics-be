print "adding scene_cid to user_activities\n"

Sequel.migration do
  change do
    add_column :user_activities, :scene_cid, String
  end
end
