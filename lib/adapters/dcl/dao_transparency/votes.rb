module Adapters
  module Dcl
    module DaoTransparency
      class Votes
        def self.call(data:)
          new(data).call
        end

        def initialize(data)
          @data = data
        end

        def call
          data[1..-1].map do |row|
            {
              address: row[0].downcase,
              proposal_id: row[1],
              created_at: row[2],
              title: row[3],
              choice: row[5],
              vote_weight: row[6].gsub(',','').to_f,
              vp: row[7].gsub(',','').to_i,
            }
          end
        end

        private
        attr_reader :data
      end
    end
  end
end
