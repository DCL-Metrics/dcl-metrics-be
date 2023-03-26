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
