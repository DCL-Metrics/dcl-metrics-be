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
          # check the date of the most recent votes saved in the db
          most_recent_data = Models::DaoVote.order(:timestamp).last&.timestamp

          data[1..-1].map do |row|
            next if most_recent_data && DateTime.parse(row[2]).to_time < most_recent_data

            {
              address: row[0].downcase,
              proposal_id: row[1],
              title: row[3],
              choice: row[5],
              vote_weight: row[6].gsub(',','').to_f,
              vp: row[7].gsub(',','').to_i,
              timestamp: row[2]
            }
          end.compact
        end

        private
        attr_reader :data
      end
    end
  end
end
