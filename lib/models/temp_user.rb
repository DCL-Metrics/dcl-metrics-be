# primary_key :id
#
# String  :address, null: false
# String  :avatar_url
# Boolean :guest
# String  :name
# Boolean :verified
#
# Time    :created_at,      null: false
#
# add_index :temp_users, :address, unique: true

module Models
  class TempUser < Sequel::Model
    def guest?
      guest
    end

    def verified?
      verified
    end
  end
end
