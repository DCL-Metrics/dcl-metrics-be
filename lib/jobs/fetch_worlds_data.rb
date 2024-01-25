module Jobs
  class FetchWorldsData < Job
    sidekiq_options queue: 'scraping', retry: false

    def perform
      data = Adapters::Dcl::Worlds.call
      Models::WorldsDump.create(
        occupied_worlds: data[:total_rooms],
        total_user_count: data[:total_user_count],
        total_world_count: data[:world_count].sum(&:last),
        dcl_world_count: data[:world_count]['dcl'],
        ens_world_count: data[:world_count]['ens'],
        data_json: data.to_json
      )
    end
  end
end
