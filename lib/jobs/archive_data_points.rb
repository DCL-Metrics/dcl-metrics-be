module Jobs
  class ArchiveDataPoints < Job
    sidekiq_options queue: 'processing'

    AuthenticationError = Class.new(::StandardError)
    FileUploadError = Class.new(::StandardError)
    B2_AUTH_URL = 'https://api.backblazeb2.com/b2api/v2/b2_authorize_account'

    def perform(date)
      date = date.to_s
      data_points = Models::DataPoint.where(date: date)
      file_name = "#{date}_data_points"
      csv_dumpfile = "#{file_name}.csv"
      tarfile = "#{file_name}.tar.gz"

      begin
        CSV.open(csv_dumpfile, 'wb') do |csv|
          # create headers row
          csv << %w[
            address
            coordinates
            date
            position
            timestamp
            scene_cid
          ]

          data_points.lazy.each_slice(1000) do |batch|
            batch.each do |row|
              csv << row.values.values.tap do |x|
                x[0] = nil  # id
                x[3] = date
                x[4] = nil  # peer_id
                x[7] = nil  # created_at
              end.compact
            end
          end
        end

        # compress csv file
        # test.csv    => 387  MB
        # test.tar.gz => 90   MB
        system("tar -czvf #{tarfile} #{csv_dumpfile}")

        # move tar file to b2
        conn = Faraday.new(B2_AUTH_URL) do |conn|
          conn.request :authorization,
            :basic,
            ENV['B2_APPLICATION_KEY_FOR_WRITING_ID'],
            ENV['B2_APPLICATION_KEY_FOR_WRITING']
        end

        response = conn.get

        raise AuthenticationError unless response.success?
        auth = JSON.parse(response.body)
        b2_get_upload_url = "#{auth['apiUrl']}/b2api/v2/b2_get_upload_url"

        response = Faraday.post(b2_get_upload_url) do |request|
          request.headers['Authorization'] = auth['authorizationToken']
          request.body = { bucketId: ENV['B2_DATA_POINTS_BUCKET_ID'] }.to_json
        end

        raise AuthenticationError unless response.success?
        upload_data = JSON.parse(response.body)
        sha1 = Digest::SHA1.new

        File.open(tarfile) do |f|
          f.lazy.each_slice(1000) do |lines|
            lines.each { |line| sha1.update(line) }
          end
        end

        # include year and date as directories for sorting purposes
        date_object = Date.parse(date)
        year = date_object.strftime('%Y')
        month = date_object.strftime('%m')
        file_to_upload = "#{year}/#{month}/#{tarfile}"

        response = Faraday.post(upload_data['uploadUrl']) do |request|
          request.headers['Authorization'] = upload_data['authorizationToken']
          request.headers['X-Bz-File-Name'] = file_to_upload
          request.headers['Content-Type'] = 'application/gzip'
          request.headers['X-Bz-Content-Sha1'] = sha1.hexdigest
          request.headers['X-Bz-Info-Author'] = 'dcl-metrics'
          request.body = File.read(tarfile)
        end

        if response.success?
          data_points.delete
        else
          raise FileUploadError, "Failed to upload #{tarfile}: #{response.body}"
        end
      rescue AuthenticationError, FileUploadError => e
        Services::TelegramOperator.notify(
          level: :error,
          message: "Failed to archive data points on #{date}",
          payload: { error_class: e.class, error_msg: e.message }
        )
      ensure
        # remove generated files
        FileUtils.rm(csv_dumpfile)
        FileUtils.rm(tarfile)
      end
    end
  end
end
