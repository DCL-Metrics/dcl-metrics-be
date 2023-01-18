module Adapters
  module Dcl
    module DaoTransparency
      class Collections
        def self.call(data:)
          new(data).call
        end

        def initialize(data)
          @data = data
        end

        def call
          data[1..-1].map do |row|
            {
              collection_id: row[0],
              name: row[1],
              symbol: row[2],
              items: row[3].to_i,
              completed: cast_boolean(row[4]),
              approved: cast_boolean(row[5]),
              created_at: row[7],
              created_by: row[10].downcase
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
