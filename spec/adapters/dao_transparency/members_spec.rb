require './spec/spec_helper'

class MembersSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::Members.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/members.csv') }
  let(:expected_delegators) do
    [
      '0x9caf2f699d62ef9602f5fc95d7f646d3c8659875',
      '0x9b04da63e17bfe3b966884439fe06318dbe03863',
      '0x103b3a31c6732c8615161757c64d2c5ed7daad38'
    ]
  end

  it 'returns the data in an expected format' do
    assert_equal(4597, subject.count)

    first = subject.first
    assert_equal('0x30b1f4bd5476906f38385b891f2c09973196b742', first[:address])
    assert_equal(728, first[:vp])
    assert_equal('0x0f051a642a1c4b2c268c7d6a83186159b149021b', first[:delegate])
    assert_equal([], first[:delegators])

    with_delagators = subject[3]
    assert_equal('0x598f8af1565003ae7456dac280a18ee826df7a2c', with_delagators[:address])
    assert_equal(174_111, with_delagators[:vp])
    assert_nil with_delagators[:delegate]
    assert_equal(expected_delegators, with_delagators[:delegators])
  end
end
