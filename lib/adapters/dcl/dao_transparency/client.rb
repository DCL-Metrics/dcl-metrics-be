module Adapters
  module Dcl
    module DaoTransparency
      class Client
        SHEET_ID = '1FoV7TdMTVnqVOZoV4bvVdHWkeu4sMH5JEhp8L0Shjlo'

        def self.fetch_data(sheet_name)
          new(sheet_name).call
        end

        def initialize(sheet_name)
          @url = "https://docs.google.com/spreadsheets/d/#{SHEET_ID}/gviz/tq"
          @base_params = { tqx: 'out:csv', response_format: 'csv' }
          @sheet_name = sheet_name
        end

        def call
          data = fetch_sheet_data(sheet_name)

          # pull out all the addresses
          addresses = collect_addresses(data)

          # if the address doesn't exist in users table then create it
          addresses.each_slice(40) do |address_batch|
            # final parameter is "only_create"
            Jobs::ProcessUsersByAddressBatch.
              perform_async(address_batch, Date.today.to_s, true)
          end

          data
        end

        private
        attr_reader :url, :base_params, :sheet_name

        def fetch_sheet_data(sheet_name)
          params = base_params.merge(sheet: sheet_name)
          response = Adapters::Base.get(url, params)

          if response.failure?
            notify_failure(sheet_name, response)
            raise RuntimeError, "#{self.class.name} failed"
          else
            adapter = Adapters::Dcl::DaoTransparency.const_get(sheet_name)
            adapter.call(data: response.success)
          end
        end

        def collect_addresses(data)
          return [] if sheet_name.downcase == 'kpis'

          [
            data.flat_map { |x| x[:address] },
            data.flat_map { |x| x[:beneficiary] },
            data.flat_map { |x| x[:created_by] },
            data.flat_map { |x| x[:delegate] },
            data.flat_map { |x| x[:delegators] }
          ].
          flatten.
          compact.
          map(&:downcase).
          uniq
        end

        def notify_failure(request, response)
          Services::TelegramOperator.notify(
            level: :error,
            message: "#{self.class.name}: #{request} request failed: #{response.failure}"
          )
        end
      end
    end
  end
end
