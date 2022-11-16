print "creating user_nfts table\n"

Sequel.migration do
  change do
    create_table(:user_nfts) do
      primary_key :id

      String    :address, null: false
      TrueClass :owns_dclens
      TrueClass :owns_land
      TrueClass :owns_wearables
      Integer   :total_dclens
      Integer   :total_lands
      Integer   :total_wearables
      Time      :first_dclens_acquired_at
      Time      :first_land_acquired_at
      Time      :first_wearable_acquired_at

      Time    :created_at,      null: false
      Time    :updated_at,      null: false
    end

    add_index :user_nfts, :address, unique: true
  end
end
