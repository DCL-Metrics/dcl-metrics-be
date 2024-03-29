module Adapters
  module Dcl
    module DaoTransparency
      class KpiClient
        FILE_ID = '1FoV7TdMTVnqVOZoV4bvVdHWkeu4sMH5JEhp8L0Shjlo'
        SHEET_ID = '624625832'

        def self.fetch_data
          new.call
        end

        def initialize
          @url = "https://docs.google.com/spreadsheets/d/#{FILE_ID}/gviz/tq"
        end

        def call
          fetch_sheet_data
        end

        private
        attr_reader :url

        def fetch_sheet_data
          params = {tqx: 'out:csv', response_format: 'csv', gid: SHEET_ID}
          response = Adapters::Base.get(url, params)

          if response.failure?
            notify_failure('KPI', response)
            raise RuntimeError, "#{self.class.name} failed"
          else
            Adapters::Dcl::DaoTransparency::KPIs.call(data: response.success)
          end
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
