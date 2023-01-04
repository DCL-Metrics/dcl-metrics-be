require './spec/spec_helper'

class GlobalParcelsSpec < BaseSpec
  before do
    create_daily_parcel_stats(data)
    Timecop.freeze(Time.utc(2022, 8, 27, 12))
  end

  after do
    Timecop.return
  end

  let(:data) { JSON.parse(File.read('./spec/fixtures/daily_parcel_stats/7d.json')) }

  let(:expected) do
    JSON.
      parse(File.read('./spec/fixtures/expectations/serializers/global_parcels.json')).
      transform_keys(&:to_sym)
  end

  let(:expected_keys) do
    %i[logins logouts time_spent time_spent_afk visitors max_concurrent_users]
  end

  it 'serializes data and returns expected output' do
    result = Serializers::Global::Parcels.serialize

    # ensure all the nodes are there
    assert_equal expected.keys, result.keys

    # ensure the nodes come out as expected
    assert_equal expected[:yesterday].transform_keys(&:to_sym),  result[:yesterday]
    assert_equal expected[:last_week].transform_keys(&:to_sym),  result[:last_week]

    # there's only 7d of data
    assert_equal expected[:last_month].transform_keys(&:to_sym),   result[:last_week]
    assert_equal expected[:last_quarter].transform_keys(&:to_sym), result[:last_week]

    # ensure the format is as expected
    yesterday = result[:yesterday].transform_keys(&:to_sym)
    assert_equal expected_keys, result[:yesterday].keys
  end
end
