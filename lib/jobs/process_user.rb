module Jobs
  class ProcessUser < Job
    sidekiq_options queue: 'processing'

    def perform(address, date, user_data_json)
      user = Models::User.find(address: address)
      user_data = JSON.parse(user_data_json)
      guest = user_data['guest'] || true
      name = user_data['name']

      if user.nil?
        Models::User.create(
          address: address,
          avatar_url: user_data['avatar_url'],
          first_seen: date,
          guest: guest,
          last_seen: date,
          name: name
        )

        # don't create additional models if the user is a guest
        Models::UserNfts.create(nft_data(address).merge(address: address)) if !guest
      else
        user.update(last_seen: date, name: name)
        Models::UserNfts.find(address: address).update(nft_data(address)) if !guest
      end
    end

    private

    def nft_data(address)
      Adapters::Dcl::NftData.call(address: address)
    end

    # NOTE TODO this one goes the other way -
    # pull the data and then make the updates based on the users in that data
    # rather than pull updates for the given user
    def dao_activity(address)
      # Models::UserDaoActivity.create(dao_activity(address))
      # wget -O test.csv --no-check-certificate
      # "https://docs.google.com/spreadsheets/d/1FoV7TdMTVnqVOZoV4bvVdHWkeu4sMH5JEhp8L0Shjlo/gviz/tq?tqx=out:csv&sheet=Members"
      #
      # sheet members for total/delegated_vp, delegators and delegate
      # sheet votes for first/last votes cast and votes cast
      # sheet proposals for proposals authored
      # sheet collections for collection creator
      # sheet team for filling memberships_json / active dao committee member
    end
  end
end