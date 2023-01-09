module Jobs
  class ProcessUserNfts < Job
    sidekiq_options queue: 'processing'

    def perform(address)
      Models::UserNfts.update_or_create(address: address) do |nft|
        nft_data(address).each { |k,v| nft.public_send("#{k}=", v) }
        nft.updated_at = Time.now.utc
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
