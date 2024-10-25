module Jobs
  class FetchSceneUtilization < Job
    sidekiq_options queue: 'processing', retry: false

    def perform
      result = ""
      conn = Faraday.new('https://api.decentraland.org/v2/tiles?include=id,updatedAt,owner')

      # pull this as chunks to make the download faster. tiles.json is ~25MB
      conn.get do |req|
        req.options.on_data = Proc.new do |chunk, size|
          result << chunk.to_s.encode('UTF-8', invalidndef: :replace, replace: '?')
        end
      end

      data = JSON.parse(result)['data']
      return nil if data.empty?

      data.values.each do |row|
        x, y = row['id'].split(',')
        last_update_at = row['updatedAt']
        owner = row['owner'].downcase

        Jobs::SaveSceneUtilization.perform_async(x, y, last_update_at, owner)
        sleep 0.2 # testing this out
      end

      nil
    end
  end
end
