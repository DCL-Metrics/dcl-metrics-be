module Jobs
  class DumpGlobalWorldsMetrics < Job
    sidekiq_options queue: 'processing'

    AuthenticationError = Class.new(::StandardError)
    FileUploadError = Class.new(::StandardError)
    B2_AUTH_URL = 'https://api.backblazeb2.com/b2api/v2/b2_authorize_account'
    BUCKET_NAME = 'global-stats'

    def perform(data)
      filename = "worlds"
      existing_file_id = nil

      begin
        # create connection for reading
        conn = Faraday.new(B2_AUTH_URL) do |conn|
          conn.request :authorization,
            :basic,
            ENV['B2_APPLICATION_KEY_FOR_READING_ID'],
            ENV['B2_APPLICATION_KEY_FOR_READING']
        end

        response = conn.get

        raise AuthenticationError unless response.success?
        auth = JSON.parse(response.body)

        # save file_id of current dumpfile
        list_files_url = "#{auth['apiUrl']}/b2api/v3/b2_list_file_versions"
        params = {
          bucketId: ENV['B2_GLOBAL_STATS_BUCKET_ID'],
          startFileName: filename
        }

        response = Faraday.get(list_files_url) do |request|
          request.headers['Authorization'] = auth['authorizationToken']
          request.params = params
        end

        if response.success?
          existing_file = JSON.parse(response.body)["files"].first
          existing_file_id = existing_file["fileId"] if existing_file
        end

        # read current dumpfile
        current = Adapters::Backblaze::ReadFile.call(bucket: BUCKET_NAME, filename: filename)

        result = if current.success? && !current.body.empty? # push new metrics
                   existing_data = JSON.parse(current.body)
                   last_timestamp =  existing_data.last['timestamp']
                   raw_data = pull_data(last_timestamp)
                   data = serialize_data(raw_data)

                   existing_data.push(data)
                 else # create dumpfile if none exists
                   raw_data = pull_data
                   serialize_data(raw_data)
                 end

        # create connection for writing
        conn = Faraday.new(B2_AUTH_URL) do |conn|
          conn.request :authorization,
            :basic,
            ENV['B2_APPLICATION_KEY_FOR_WRITING_ID'],
            ENV['B2_APPLICATION_KEY_FOR_WRITING']
        end
        response = conn.get

        raise AuthenticationError unless response.success?
        auth = JSON.parse(response.body)

        # re-upload dumpfile
        b2_get_upload_url = "#{auth['apiUrl']}/b2api/v2/b2_get_upload_url"

        response = Faraday.post(b2_get_upload_url) do |request|
          request.headers['Authorization'] = auth['authorizationToken']
          request.body = { bucketId: ENV['B2_GLOBAL_STATS_BUCKET_ID'] }.to_json
        end

        raise AuthenticationError unless response.success?
        upload_data = JSON.parse(response.body)
        sha1 = Digest::SHA1.new
        json_result = result.to_json
        sha1.update(json_result)

        response = Faraday.post(upload_data['uploadUrl']) do |request|
          request.headers['Authorization'] = upload_data['authorizationToken']
          request.headers['X-Bz-File-Name'] = filename
          request.headers['Content-Type'] = 'application/json'
          request.headers['X-Bz-Content-Sha1'] = sha1.hexdigest
          request.headers['X-Bz-Info-Author'] = 'dcl-metrics'
          request.body = json_result
        end

        if response.success?
          puts "--- global worlds metrics dumped successfully"

          if existing_file_id
            # delete previous dumpfile
            b2_delete_file_url = "#{auth['apiUrl']}/b2api/v3/b2_delete_file_version"
            response = Faraday.post(b2_get_upload_url) do |request|
              request.headers['Authorization'] = auth['authorizationToken']
              request.body = { field: existing_file_id }.to_json
            end
          end
        else
          raise FileUploadError, "Failed to upload global world metrics: #{response.body}"
        end
      rescue AuthenticationError, FileUploadError => e
        Services::TelegramOperator.notify(
          level: :error,
          message: "Failed to dump global worlds metrics",
          payload: { error_class: e.class, error_msg: e.message }
        )
      end
    end

    private

    def pull_data(after_timestamp = nil)
      base_query = "select created_at as timestamp,
                           (data_json ->> 'total_user_count')::int as total_user_count,
                           (data_json ->> 'total_rooms')::int as occupied_worlds,
                           (data_json ->> 'world_count') as world_count
                   from worlds_dump "

      base_query += "where created_at > '#{after_timestamp.to_s}' " if after_timestamp

      DATABASE_CONNECTION[base_query + "order by created_at"][1..-1]
    end

    def serialize_data(data)
      # TODO: this is still not working right
      data.map do |row|
        world_count = JSON.parse(row[:world_count] || '{}')
        dcl_count = world_count.is_a?(Hash) ? world_count['dcl'].to_i : 0
        ens_count = world_count.is_a?(Hash) ? world_count['ens'].to_i : 0

        total = if world_count.is_a?(Integer)
                  world_count
                else
                  dcl_count + ens_count
                end

        {
          timestamp: row[:timestamp],
          total_user_count: row[:total_user_count],
          occupied_worlds: row[:occupied_worlds],
          world_count: {
            total: total,
            dcl: dcl_count,
            ens: ens_count
          }
        }
      end
    end
  end
end
