require './spec/spec_helper'

class MembersSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::Members.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/members.csv') }
  let(:expected_delegators) do
    %w[
      0x9caf2f699d62ef9602f5fc95d7f646d3c8659875
      0x9b04da63e17bfe3b966884439fe06318dbe03863
      0x103b3a31c6732c8615161757c64d2c5ed7daad38
      0x18c6d15ecaa60d92d38cc5b89cd3f65179d30c86
      0x6a13c5edbe4f48507dcdcc28466d79b519b049b7
      0xcdc61e1c068342d88cd9fb730414d9ef5ba5849e
      0x91cfd8bdd7161a368c0804c09029a4760d4387e1
      0xf69f0a71d49a0c2fe481bbb148cc99e6e02a8dbb
      0x421075d4256422ad906de024571d3021c282a1be
      0xb5c8f264daf84bac8fa382a9476d8672b533d7ec
    ]
  end

  it 'returns the data in an expected format' do
    assert_equal(10, subject.count)

    first = subject.first
    assert_equal('0x30b1f4bd5476906f38385b891f2c09973196b742', first[:address])
    assert_equal(4154, first[:vp])
    assert_equal('0x0f051a642a1c4b2c268c7d6a83186159b149021b', first[:delegate])
    assert_equal([], first[:delegators])

    with_delagators = subject[3]
    assert_equal('0x598f8af1565003ae7456dac280a18ee826df7a2c', with_delagators[:address])
    assert_equal(652_713, with_delagators[:vp])
    assert_nil with_delagators[:delegate]
    assert_equal(10, with_delagators[:delegators].count)
    assert_equal(expected_delegators, with_delagators[:delegators])
  end
end
