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
    TERRAFORM_DISPERSAL_DATE = DateTime.parse('2018-02-01').to_time
    LAUNCH_DATE = DateTime.parse('2020-03-01').to_time

    def self.stale
      # where { updated_at <= Date.today - 3 }
      where { updated_at <= Date.today - 10 }
    end

    def user
      Models::User.find(address: address)
    end

    def verified?
      owns_dclens
    end

    def og?
      return true if participated_in_genesis_auction?
      return true if first_dclens_acquired_at < LAUNCH_DATE
      return true if first_wearable_acquired_at < LAUNCH_DATE
    end

    def participated_in_genesis_auction?
      first_land_acquired_at < TERRAFORM_DISPERSAL_DATE
    end
  end
end
