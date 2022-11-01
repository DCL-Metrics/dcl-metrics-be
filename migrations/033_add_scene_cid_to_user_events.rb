print "adding scene_cid to user_events\n"

Sequel.migration do
  change do
    add_column :user_events, :scene_cid, String
  end
end
