module Jobs
  class ProcessUser < Job
    sidekiq_options queue: 'processing'

    def perform(address, date, guest, name, avatar_url)
      user = Models::User.find(address: address)

      if user.nil?
        Models::User.create(
          address: address,
          avatar_url: avatar_url,
          first_seen: date,
          guest: guest,
          last_seen: date,
          name: name
        )
      else
        return if user.last_seen > Date.parse(date)

        user.update(last_seen: date, name: name)
      end
    end
  end
end
