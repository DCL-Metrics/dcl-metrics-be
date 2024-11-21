module Jobs
  class ArchivePeersDump < Job
    sidekiq_options queue: 'processing'

    AuthenticationError = Class.new(::StandardError)
    FileUploadError = Class.new(::StandardError)
    B2_AUTH_URL = 'https://api.backblazeb2.com/b2api/v2/b2_authorize_account'

    def perform(date)
      date = date.to_s
      peers_dump = Models::PeersDump.where(created_at: ("#{date} 00:00:00".."#{date} 23:59:59"))
      return if peers_dump.count.zero?

      file_name = "#{date}_peers_dump"
      csv_dumpfile = "#{file_name}.csv"
      tarfile = "#{file_name}.tar.gz"

      begin
        # stream data into CSV file
        CSV.open(csv_dumpfile, 'w+') do |csv|
          # write headers
          csv << %w[
            timestamp
            address
            coordinate_x
            coordinate_y
            lastPing
            position_x
            position_y
            position_z
            scene_cid
          ]

          # write data
          peers_dump.each do |dump|
            dump = Models::PeersDump.new(dump.except(:id)) if dump.is_a?(Hash)
            timestamp = dump[:created_at].to_s

            dump.data.each do |row|
              next if row['parcel'].nil?

              csv << [
                timestamp,
                row['address'],
                row['parcel'][0],
                row['parcel'][1],
                row['lastPing'],
                row['position'][0],
                row['position'][1],
                row['position'][2],
                row['scene_cid']
              ]
            end
          end
        end

        # compress csv file
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
          request.body = { bucketId: ENV['B2_PEERS_DUMP_BUCKET_ID'] }.to_json
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
          peers_dump.delete
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
