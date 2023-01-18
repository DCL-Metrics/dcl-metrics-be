module Adapters
  module Dcl
    module DaoTransparency
      class ActivityWrapper
        # TODO: get rid of this and fetch individually

        SHEET_ID = '1FoV7TdMTVnqVOZoV4bvVdHWkeu4sMH5JEhp8L0Shjlo'

        # sheet names
        COLLECTIONS = 'Collections'
        GRANTS = 'Grants'
        KPIS = 'KPIs'
        MEMBERS = 'Members'
        PROPOSALS = 'Proposals'
        TEAM = 'Team'
        VOTES = 'Votes'

        def self.call
          new.call
        end

        def initialize
          @url = "https://docs.google.com/spreadsheets/d/#{SHEET_ID}/gviz/tq"
          @base_params = { tqx: 'out:csv', response_format: 'csv' }
        end

        def call
          collections = fetch_sheet_data(COLLECTIONS)
          grants = fetch_sheet_data(GRANTS)
          kpis = fetch_sheet_data(KPIS)
          members = fetch_sheet_data(MEMBERS)
          proposals = fetch_sheet_data(PROPOSALS)
          team = fetch_sheet_data(TEAM)
          votes = fetch_sheet_data(VOTES)
          all = [members, votes, proposals, grants, collections, team]

          # 1. pull all the addresses from all sheets
          addresses = all.
            flat_map do |sheet|
              [
                sheet.flat_map { |x| x[:address] },
                sheet.flat_map { |x| x[:beneficiary] },
                sheet.flat_map { |x| x[:created_by] },
                sheet.flat_map { |x| x[:delegate] },
                sheet.flat_map { |x| x[:delegators] }
              ]
            end.
            flatten.
            compact.
            map(&:downcase).
            uniq

          # 2. if the address doesn't exist in users table then create it
          addresses.each_slice(40) do |address_batch|
            final parameter is "only_create"
            Jobs::ProcessUsersByAddressBatch.perform_async(address_batch, Time.now.utc, true)
          end

          {
            addresses: addresses,
            kpis: kpis,
            members: members,
            votes: votes,
            proposals: proposals,
            grants: grants,
            collections: collections,
            team: team
          }
        end

        private
        attr_reader :url, :base_params

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
