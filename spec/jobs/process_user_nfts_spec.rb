require './spec/spec_helper'

class ProcessUserNftsSpec < BaseSpec
  subject { Jobs::ProcessUserNfts.perform_async(address) }

  let(:address_with_nfts) { '0x26a6405a3edb23db55de9a5bb1fa678011db67af' }
  let(:address_without_nfts) { '0x6445258e1a081fe469e1021a1b018306a3d2bb15' }
  let(:result) { Models::UserNfts.last.values }

  describe 'when no user_nfts model exists for given address' do
    describe 'when the address has no nfts' do
      let(:address) { address_without_nfts }

      it 'creates a new model' do
        assert_equal 0, Models::UserNfts.count
        subject
        assert_equal 1, Models::UserNfts.count
      end

      it 'sets expected attributes' do
        subject

        assert_equal address, result[:address]
        assert_equal false, result[:owns_dclens]
        assert_equal false, result[:owns_land]
        assert_equal false, result[:owns_wearables]
        assert_equal 0, result[:total_dclens]
        assert_equal 0, result[:total_lands]
        assert_equal 0, result[:total_wearables]
        assert_nil result[:first_dclens_acquired_at]
        assert_nil result[:first_land_acquired_at]
        assert_nil result[:first_wearable_acquired_at]
        assert_in_delta Time.now.utc.to_i, result[:updated_at].to_i, 1
      end
    end

    describe 'when the address owns nfts' do
      let(:address) { address_with_nfts }

      it 'creates a new model' do
        assert_equal 0, Models::UserNfts.count
        subject
        assert_equal 1, Models::UserNfts.count
      end

      it 'sets expected attributes' do
        subject

        assert_equal address, result[:address]
        assert_equal false, result[:owns_dclens]
        assert_equal false, result[:owns_land]
        assert_equal true, result[:owns_wearables]
        assert_equal 0, result[:total_dclens]
        assert_equal 0, result[:total_lands]
        assert_equal 408, result[:total_wearables]
        assert_nil result[:first_dclens_acquired_at]
        assert_nil result[:first_land_acquired_at]
        assert_equal '2021-12-14', result[:first_wearable_acquired_at].to_date.to_s
        assert_in_delta Time.now.utc.to_i, result[:updated_at].to_i, 1
      end
    end
  end

  describe 'when a user_nfts model exists for given address' do
    before do
      model = Models::UserNfts.create(address: address)
      model.update(updated_at: Time.now.utc - 3600)
    end

    describe 'when the address has no nfts' do
      let(:address) { address_without_nfts }

      it 'does not create a new model' do
        assert_equal 1, Models::UserNfts.count
        subject
        assert_equal 1, Models::UserNfts.count
      end

      # regression test
      it 'updates the "updated_at" attribute' do
        subject

        assert_in_delta Time.now.utc.to_i, result[:updated_at].to_i, 1
      end
    end

    describe 'when the address owns nfts' do
      let(:address) { address_with_nfts }

      it 'does not create a new model' do
        assert_equal 1, Models::UserNfts.count
        subject
        assert_equal 1, Models::UserNfts.count
      end

      # regression test
      it 'updates the "updated_at" attribute' do
        subject

        assert_in_delta Time.now.utc.to_i, result[:updated_at].to_i, 1
      end
    end
  end
end

class Adapters::Dcl::NftData
  def self.call(address:)
    JSON.parse(File.read("./spec/fixtures/user_nfts/#{address}.json"))
  end
end
