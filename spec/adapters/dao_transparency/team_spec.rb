require './spec/spec_helper'

class TeamSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::Team.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/team.csv') }

  it 'returns the data in an expected format' do
    assert_equal(25, subject.count)

    first = subject.first
    assert_equal('0xfc4ef0903bb924d06db9cbaba1e4bda6b71d2f82', first[:address])
    assert_equal('Security Advisory Board', first[:team])
    assert_equal(true, first[:active])
  end
end
