module Adapters
  module Dcl
    module DaoTransparency
      class KPIs
        WHALE_VP_MINIMUM = 1_000_000
        SHARK_VP_MINIMUM = 100_000
        DOLPHIN_VP_MINIMUM = 10_000
        FISH_VP_MINIMUM = 1000
        CRAB_VP_MINIMUM = 1

        def self.call(data:)
          new(data).call
        end

        def initialize(data)
          @data = data
        end

        def call
          proposals_by_status = fetch_following('Proposals by Status', 5)
          vp_sources = fetch_following('VP sources', 5)

          whales = fetch('Members w/ >=1M VP')
          sharks = fetch('Members w/ >=100k VP')
          dolphins = fetch('Members w/ >=10k VP')
          fish = fetch('Members w/ >=1k VP')
          crabs = fetch('Members w/ <1k VP')

          {
            active_members: fetch('Active members')[1].to_i,
            total_vp: fetch('totalVP')[2].to_i,
            total_votes: fetch('Total Votes')[1].to_i,
            proposals: {
              total: fetch('Proposals created')[1].to_i,
              active: proposals_by_status[0][1].to_i,
              active_percent: proposals_by_status[0][2].to_f,
              enacted: proposals_by_status[1][1].to_i,
              enacted_percent: proposals_by_status[1][2].to_f,
              finished: proposals_by_status[2][1].to_i,
              finished_percent: proposals_by_status[2][2].to_f,
              passed: proposals_by_status[3][1].to_i,
              passed_percent: proposals_by_status[3][2].to_f,
              rejected: proposals_by_status[4][1].to_i,
              rejected_percent:proposals_by_status[4][2].to_f,
            },
            vp_sources: {
              mana: {
                members: vp_sources[1][1].to_i,
                amount: vp_sources[1][2].to_i,
                percent: vp_sources[1][3].to_f,
              },
              land: {
                members: vp_sources[2][1].to_i,
                amount: vp_sources[2][2].to_i,
                percent: vp_sources[2][3].to_f,
              },
              names: {
                members: vp_sources[3][1].to_i,
                amount: vp_sources[3][2].to_i,
                percent: vp_sources[3][3].to_f,
              },
              delegated: {
                members: vp_sources[4][1].to_i,
                amount: vp_sources[4][2].to_i,
                percent: vp_sources[4][3].to_f,
              }
            },
            vp_distribution: {
              whales: {
                minimum_vp: WHALE_VP_MINIMUM,
                members: whales[1].to_i,
                percent: whales[2].to_f,
                percent_of_total_vp: whales[4].to_f,
              },
              sharks: {
                minimum_vp: SHARK_VP_MINIMUM,
                members: sharks[1].to_i,
                percent: sharks[2].to_f,
                percent_of_total_vp: sharks[4].to_f,
              },
              dolphins: {
                minimum_vp: DOLPHIN_VP_MINIMUM,
                members: dolphins[1].to_i,
                percent: dolphins[2].to_f,
                percent_of_total_vp: dolphins[4].to_f,
              },
              fish: {
                minimum_vp: FISH_VP_MINIMUM,
                members: fish[1].to_i,
                percent: fish[2].to_f,
                percent_of_total_vp: fish[4].to_f,
              },
              crabs: {
                minimum_vp: CRAB_VP_MINIMUM,
                members: crabs[1].to_i,
                percent: crabs[2].to_f,
                percent_of_total_vp: crabs[4].to_f,
              }
            }
          }
        end

        private
        attr_reader :data

        def fetch(first_string)
          data.detect { |x| x.first == first_string }
        end

        def fetch_following(string, count)
          current = fetch(string)
          index = data.index(current)
          data[index + 1..index + count]
        end
      end
    end
  end
end
