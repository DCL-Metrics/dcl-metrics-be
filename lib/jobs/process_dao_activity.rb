module Jobs
  class ProcessDaoActivity < Job
    sidekiq_options queue: 'processing'

    def perform(sheet_name)
      governance = Models::DaoGovernance.last
      data = Adapters::Dcl::DaoTransparency::Client.fetch_data(sheet_name).to_json
      existing_data = governance.public_send("#{sheet_name.downcase}_json")

      if data != existing_data
        governance.update("#{sheet_name.downcase}_json" => data)
        Jobs::UserDaoActivities.const_get(sheet_name).perform_async if sheet_name != 'KPIs'
      end

      # either way update the relevant DaoGovernance#updated_at column
      governance.update("#{sheet_name.downcase}_updated_at" => Time.now.utc)
    end
  end
end
