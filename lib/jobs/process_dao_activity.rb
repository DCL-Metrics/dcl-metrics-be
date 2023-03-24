module Jobs
  class ProcessDaoActivity < Job
    sidekiq_options queue: 'processing'

    def perform(sheet_name)
      governance = Models::DaoGovernance.last
      data = Adapters::Dcl::DaoTransparency::Client.fetch_data(sheet_name).to_json

      if sheet_name == 'Votes'
        # NOTE: votes has a LOT more data than the other sheets,
        # so a different approach is needed
        data.each { |v| create_vote(v) }
      else
        sheet_name.downcase!
        existing_data = governance.public_send("#{sheet_name}_json")

        update_params = { "#{sheet_name}_updated_at" => Time.now.utc }
        update_params.merge!("#{sheet_name}_json" => data) if data != existing_data

        governance.update(update_params)
      end
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
