module Adapters
  module Dcl
    class NftData
      URL = 'https://nft-api.decentraland.org/v1/nfts'
      PARCEL_CATEGORY = 'parcel'
      ESTATE_CATEGORY = 'estate'
      NAME_CATEGORY = 'ens'
      WEARABLE_CATEGORY = 'wearable'
      PER_PAGE = 1000

      def self.call(address:)
        new(address).call
      end

      def initialize(address)
        @address = address
        @result = {}
      end

      def call
        result.
          merge(land_data).
          merge(name_data).
          merge(wearable_data)
      end

      private
      attr_reader :address, :result

      def land_data
        parcels = base_response(PARCEL_CATEGORY)
        estates = base_response(ESTATE_CATEGORY)
        # NOTE: either of these can be nil
        lands = [parcels['data'], estates['data']].compact.flatten
        total_lands = count_total_lands(parcels, estates)

        {
          owns_land: !!lands&.any?,
          total_lands: total_lands,
          first_land_acquired_at: first_acquisition(lands)
        }
      end

      def name_data
        names = base_response(NAME_CATEGORY)

        {
          owns_dclens: !!names['data']&.any?,
          total_dclens: names['total'],
          first_dclens_acquired_at: first_acquisition(names['data'])
        }
      end

      def wearable_data
        wearables = base_response(WEARABLE_CATEGORY)

        {
          owns_wearables: !!wearables['data']&.any?,
          total_wearables: wearables['total'],
          first_wearable_acquired_at: first_acquisition(wearables['data'])
        }
      end

      def first_acquisition(data)
        return nil unless data

        timestamp = data.map { |e| e['nft']['updatedAt'] }.sort.first
        return nil unless timestamp

        Time.at(timestamp / 1000).utc
      end

      def count_total_lands(parcels, estates)
        estates_data = estates['data']

        parcels_in_estates = estates_data.nil? ? 0 : count_estate_parcels(estates_data)
        parcel_count = parcels['total'].nil? ? 0 : parcels['total']

        parcels_in_estates + parcel_count
      end

      def count_estate_parcels(estates)
        estates.
          map { |estate| estate.dig('nft', 'data', 'estate', 'size') }.
          sum
      end

      def base_response(category, attempt: 1, skip: 0)
        response = Adapters::Base.get(URL, query_params(category, skip))
        return {} if response.failure?

        if response.success['total'] > (attempt * PER_PAGE)
          return base_response(category, attempt: attempt +1, skip: PER_PAGE * attempt)
        else
          response.success
        end
      end

      def query_params(category, skip = 0)
        { owner: address, first: PER_PAGE, skip: skip, category: category }
      end
    end
  end
end
