module Adapters
  module Dcl
    module DaoTransparency
      class Grants
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

            proposal
          end
        end

        private
        attr_reader :data
      end
    end
  end
end


