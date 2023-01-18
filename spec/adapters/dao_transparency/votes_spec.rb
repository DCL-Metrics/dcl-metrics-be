require './spec/spec_helper'

class VotesSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::Votes.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/votes.csv') }

  it 'returns the data in an expected format' do
    assert_equal(52942, subject.count)

    first = subject.first
    assert_equal('0x30b1f4bd5476906f38385b891f2c09973196b742', first[:address])
    assert_equal('QmbYNKMYJMrud9VzhsCDHZXbSD2t7HkbPzwtFCPL2dBvxv', first[:proposal_id])
    assert_equal('2021-05-24T15:29:29.000Z', first[:created_at])
    assert_equal('Add the location 25,74 to the Points of Interest', first[:title])
    assert_equal('yes', first[:choice])
    assert_equal(2.941741358, first[:vote_weight])
    assert_equal(16_005, first[:vp])
  end
end
