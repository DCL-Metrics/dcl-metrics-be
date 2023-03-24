require './spec/spec_helper'

class VotesSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::Votes.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/votes.csv') }

  it 'returns the data in an expected format' do
    assert_equal(27, subject.count)

    first = subject.first
    assert_equal('0x631ab8eb40588543df900263f864b6376d56a587', first[:address])
    assert_equal('0x5180e81e02085b59fd9c4a457f89270b38fd7bc27fece7c716b9620c4b818a9b', first[:proposal_id])
    assert_equal('2023-01-17T05:53:01.000Z', first[:timestamp])
    assert_equal('What is the best name for the Accountability Commitee?', first[:title])
    assert_equal('Grant Revocations Committee', first[:choice])
    assert_equal(0.0001789248489, first[:vote_weight])
    assert_equal(2, first[:vp])
  end

  describe 'when some votes already exist in the database' do
    before do
      Models::DaoVote.create(
        address: '0x..',
        proposal_id: SecureRandom.uuid,
        title: 'title',
        choice: 'yes',
        vote_weight: 1,
        vp: 100,
        timestamp: DateTime.parse('2023-01-17T06:00:00.000Z').to_time
      )
    end

    it 'only returns votes newer than what exist in the db' do
      assert_equal(21, subject.count)
    end
  end
end
