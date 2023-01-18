require './spec/spec_helper'

class CollectionsSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::Collections.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/collections.csv') }

  it 'returns the data in an expected format' do
    assert_equal(4234, subject.count)

    first = subject.first
    assert_equal('0xf6d8e606c862143556b342149a7fe0558c220375', first[:collection_id])
    assert_equal('Polygon Thunder 2021', first[:name])
    assert_equal('DCL-PLYGNTHNDR2021', first[:symbol])
    assert_equal(7, first[:items])
    assert_equal(true, first[:completed])
    assert_equal(true, first[:approved])
    assert_equal("2021-06-09T16:30:35.000Z", first[:created_at])
    assert_equal('0x6adf75e49bac21abab9adb9266d2cc6d90abd31a', first[:created_by])
  end
end
