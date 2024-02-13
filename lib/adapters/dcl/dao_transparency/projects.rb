module Adapters
  module Dcl
    module DaoTransparency
      class Projects
        def self.call(data:)
          new(data).call
        end

        def initialize(data)
          @data = data
        end

        def call
          data[1..-1].map do |row|
            status = row[4]

            proposal = {
              proposal_id: row[0],
              snapshot_id: row[1],
              created_by: row[2].downcase,
              title: row[3],
              status: status,
              started_at: row[5],
              ended_at: row[6],
              category: row[9],
              tier: row[10].split.last.to_i,
              amount: row[11].to_i,
              beneficiary: row[12].downcase,
            }

            if status == 'enacted'
              proposal.merge!(
                vesting_contract: row[14].downcase,
                vesting_released: row[15].to_i,
                done_updates: row[24].sub('$', '').to_i,
                late_updates: row[25].sub('$', '').to_i,
                missed_updates: row[26].sub('$', '').to_i,
                remaining_updates: row[31].sub('$', '').to_i,
                health: row[28]
              )
            end

            proposal
          end
        end

        private
        attr_reader :data
      end
    end
  end
end


