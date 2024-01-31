module Jobs
  class ProcessDaoActivity < Job
    sidekiq_options queue: 'processing'

    def perform(sheet_name)
      data = if sheet_name == 'KPIs'
               Adapters::Dcl::DaoTransparency::KpiClient.fetch_data
             else
               Adapters::Dcl::DaoTransparency::Client.fetch_data(sheet_name)
             end

      if sheet_name == 'Votes'
        # NOTE: votes has a LOT more data than the other sheets,
        # so a different approach is needed
        data.each { |v| create_vote(v) }
      else
        data = data.to_json
        governance = Models::DaoGovernance.last
        existing_data = governance.public_send("#{sheet_name.downcase}_json")

        update_params = { "#{sheet_name.downcase}_updated_at" => Time.now.utc }
        update_params.merge!("#{sheet_name.downcase}_json" => data) if data != existing_data

        governance.update(update_params)
      end

      return if sheet_name == 'KPIs'
      Jobs::UserDaoActivities.const_get(sheet_name).perform_async
      nil
    end

    private

    def create_vote(vote)
      Models::DaoVote.create(
        address: vote[:address],
        proposal_id: vote[:proposal_id],
        title: vote[:title],
        choice: vote[:choice],
        vote_weight: vote[:vote_weight],
        vp: vote[:vp],
        timestamp: vote[:timestamp]
      )
    end
  end
end
