module Jobs
  class DumpGlobalUniqueDailyMetrics < Job
    sidekiq_options queue: 'processing'

    AuthenticationError = Class.new(::StandardError)
    FileUploadError = Class.new(::StandardError)
    B2_AUTH_URL = 'https://api.backblazeb2.com/b2api/v2/b2_authorize_account'
    BUCKET_NAME = 'global-stats'

    def perform
      filename = "unique-daily"
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
                   data_cutoff_index = -3
                   existing_data = JSON.parse(current.body)
                   last_entry_date =  existing_data.keys[data_cutoff_index]
                   data = pull_data(last_entry_date)

                   # remove the last x days of data from existing data
                   existing_data.keys[data_cutoff_index..-1].each do |date|
                     existing_data.delete(date)
                   end

                   existing_data + data
                 else # create dumpfile if none exists
                   pull_data
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
          puts "--- global unique users metrics dumped successfully"

          if existing_file_id
            # delete previous dumpfile
            b2_delete_file_url = "#{auth['apiUrl']}/b2api/v3/b2_delete_file_version"
            response = Faraday.post(b2_delete_file_url) do |request|
              request.headers['Authorization'] = auth['authorizationToken']
              request.body = { fileId: existing_file_id, fileName: filename }.to_json
            end
          end
        else
          raise FileUploadError, "Failed to upload global unique users metrics: #{response.body}"
        end
      rescue AuthenticationError, FileUploadError => e
        Services::TelegramOperator.notify(
          level: :error,
          message: "Failed to dump global unique users metrics",
          payload: { error_class: e.class, error_msg: e.message }
        )
      end
    end

    private

    def pull_data(after_timestamp = nil)
      Serializers::Global::DailyStats.serialize(after_timestamp)
    end
  end
end
