require './spec/spec_helper'

class ProposalsSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::Proposals.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/proposals.csv') }

  it 'returns the data in an expected format' do
    assert_equal(1511, subject.count)

    first = subject.first
    assert_equal('e8de87c0-957a-11ed-ae61-5f6dd0bf8358', first[:proposal_id])
    assert_equal('0x714d66ac7661dde0839cd4e97ab6568ee303bcc81ce8a23d9c92642895052724', first[:snapshot_id])
    assert_equal('0xb357e7575a780980e4cee86654a6acd0cc13b77f', first[:created_by])
    assert_equal('linked_wearables', first[:category])
    assert_includes(first[:title], 'FANCY BEARS')
    assert_equal('2023-01-16T08:51:00.380Z', first[:start_time])
    assert_equal('2023-01-23T08:51:00.379Z', first[:end_time])
    assert_equal('active', first[:status])
    assert_equal(111, first[:total_votes])
  end
end
