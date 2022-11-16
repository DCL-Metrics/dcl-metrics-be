# primary_key :id
#
# String    :address, null: false
# TrueClass :owns_dclens
# TrueClass :owns_land
# TrueClass :owns_wearables
# Integer   :total_dclens
# Integer   :total_lands
# Integer   :total_wearables
# Time      :first_dclens_acquired_at
# Time      :first_land_acquired_at
# Time      :first_wearable_acquired_at
#
# Time    :created_at,      null: false
# Time    :updated_at,      null: false
#
# add_index :user_nfts, :address, unique: true

module Models
  class UserNfts < Sequel::Model(FAT_BOY_DATABASE[:user_nfts])
    one_to_one :user, key: :address

    def verified?
      owns_dclens
    end

    def og?
      # land acquired before x date
      # dclens acquired before y date
      # wearable acquired before z date
    end

    def genesis_auction?
      # first_land_acquired_on < date of land dispersal
    end
  end
end
