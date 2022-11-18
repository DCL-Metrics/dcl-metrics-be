module Jobs
  class ProcessUsersNfts < Job
    sidekiq_options queue: 'processing'

    def perform
      Models::User.where(guest: false).each_slice(1000) do |users|
        users.each { |u| Jobs::ProcessUserNfts.perform_async(address: u.address) }
      end
    end
  end
end
