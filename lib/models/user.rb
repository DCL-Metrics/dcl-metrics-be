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
    one_to_one :user_nfts, left_key: :address, right_key: :address
    one_to_one :user_dao_activity, left_key: :address, right_key: :address

    def verified?
      user_nfts.owns_dclens
    end
  end
end
