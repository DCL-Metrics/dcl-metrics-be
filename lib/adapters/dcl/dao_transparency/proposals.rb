module Adapters
  module Dcl
    module DaoTransparency
      class Proposals
        def self.call(data:)
          new(data).call
        end

        def initialize(data)
          @data = data
        end

        def call
          data[1..-1].map do |row|
            {
              proposal_id: row[0],
              snapshot_id: row[1],
              created_by: row[2].downcase,
              category: row[3],
              title: row[4],
              start_time: row[5],
              end_time: row[6],
              status: row[8],
              total_vp: row[10],
              total_votes: row[15].to_i
            }
          end
        end

        private
        attr_reader :data
      end
    end
  end
end
