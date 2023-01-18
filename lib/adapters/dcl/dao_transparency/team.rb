module Adapters
  module Dcl
    module DaoTransparency
      class Team
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
              team: row[1],
              active: cast_boolean(row[2])
            }
          end
        end

        private
        attr_reader :data

        def cast_boolean(str)
          return true if str == 'TRUE'
          false
        end
      end
    end
  end
end
