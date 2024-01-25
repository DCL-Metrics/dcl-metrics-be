print "add columns to worlds_dump table\n"

Sequel.migration do
  change do
    add_column :worlds_dump, :occupied_worlds, Integer
    add_column :worlds_dump, :total_user_count, Integer
    add_column :worlds_dump, :total_world_count, Integer
    add_column :worlds_dump, :dcl_world_count, Integer
    add_column :worlds_dump, :ens_world_count, Integer
  end
end
