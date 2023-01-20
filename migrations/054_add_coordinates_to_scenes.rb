print "adding coordinates to scenes\n"

Sequel.migration do
  change do
    add_column :scenes, :coordinates, String
  end
end
