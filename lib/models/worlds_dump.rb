# primary_key :id
#
# Jsonb   :data_json,   null: false
# Time    :created_at,  null: false
#
# add_index :worlds_dump, :created_at, unique: true

module Models
  class WorldsDump < Sequel::Model(FAT_BOY_DATABASE[:worlds_dump])
    def data
      @data ||= JSON.parse(data_json)
    end
  end
end
