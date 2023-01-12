module Jobs
  class FetchWorldsData < Job
    sidekiq_options queue: 'scraping', retry: false

    def perform
      data = Adapters::Dcl::Worlds.call
      Models::WorldsDump.create(data_json: data.to_json)
    end
  end
end
