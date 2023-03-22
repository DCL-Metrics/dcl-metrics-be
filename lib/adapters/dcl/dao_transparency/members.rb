module Adapters
  module Dcl
    module DaoTransparency
      class Members
        def self.call(data:)
          new(data).call
        end

        def initialize(data)
          @data = data
        end

        def call
          data[1..-1].map do |row|
            delegate = row[9].empty? ? nil : row[9].downcase

            {
              address: row[0].downcase,
              vp: row[1].gsub(',','').to_i,
              delegated_vp: row[5].gsub(',','').to_i,
              delegate: delegate,
              delegators: row[12].split(',').map(&:downcase)
            }
          end
        end

        private
        attr_reader :data
      end
    end
  end
end
