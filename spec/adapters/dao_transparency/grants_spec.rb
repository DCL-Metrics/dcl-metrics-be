require './spec/spec_helper'

class GrantsSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::Grants.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/grants.csv') }

  it 'returns the data in an expected format' do
    assert_equal(414, subject.count)

    first = subject.first
    assert_equal(11, first.keys.count)
    assert_equal('c28e0b10-8830-11ed-bd37-2b7f3eae6b63', first[:proposal_id])
    assert_equal('0x376604a5525d4920c30ef0397e75cd9ef390f53253d5aa6275a827a4541fd912', first[:snapshot_id])
    assert_equal('0xdce7d7f3ea933b214b1e73b47b079b631122596e', first[:created_by])
    assert_equal('re: FIRST METAVERSE ARCHITECTURE & DESIGN BIENNALE (updates, event announce)', first[:title])
    assert_equal('rejected', first[:status])
    assert_equal('2022-12-30T10:57:00.225Z', first[:started_at])
    assert_equal('2023-01-13T10:57:00.224Z', first[:ended_at])
    assert_equal('Community', first[:category])
    assert_equal(4, first[:tier])
    assert_equal(60_000, first[:amount])
    assert_equal('0xdce7d7f3ea933b214b1e73b47b079b631122596e', first[:beneficiary])

    enacted = subject[23]
    assert_equal(12, enacted.keys.count)
    assert_equal('29b3a3a0-74fd-11ed-a9bf-f772a12a0556', enacted[:proposal_id])
    assert_equal('0x3603c2cc8bf90257aa3da37e3f2549058f5b2f272b8285b2f0bd9684e57a7592', enacted[:snapshot_id])
    assert_equal('0x56469159d91eb810dce34dd13ec4ed8194bca7be', enacted[:created_by])
    assert_equal('Vroomway Continuation - Revised', enacted[:title])
    assert_equal('enacted', enacted[:status])
    assert_equal('2022-12-06T00:30:00.354Z', enacted[:started_at])
    assert_equal('2022-12-20T00:30:00.353Z', enacted[:ended_at])
    assert_equal('Gaming', enacted[:category])
    assert_equal(5, enacted[:tier])
    assert_equal(120_000, enacted[:amount])
    assert_equal('0x4b99ad2fad8b5553dc734eda80695591b3ca1fd5', enacted[:beneficiary])
    assert_equal('0xf265a437cc3566492221266b69ef69dd8936aa4c', enacted[:vesting_contract])
  end
end
