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
  end
end
