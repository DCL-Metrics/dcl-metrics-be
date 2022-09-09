class GlobalDailyStatsSpec < BaseSpec
  before do
    create_daily_stats(data)
    Timecop.freeze(Time.utc(2022, 8, 31, 12))
  end

  after do
    Timecop.return
  end

  let(:data) { JSON.parse(File.read('./spec/fixtures/daily_stats/30d.json')) }

  let(:expected) do
    JSON.
      parse(File.read('./spec/fixtures/expectations/serializers/global_daily_stats.json'))
  end

  let(:expected_keys) { %i[unique_users active_parcels] }

  it 'serializes data and returns expected output' do
    result = Serializers::Global::DailyStats.serialize

    # ensure all the nodes are there
    assert_equal expected.keys.count, result.keys.count

    # ensure the nodes come out as expected
    assert_equal expected, result.stringify_keys

    # ensure the format is as expected
    assert_equal expected_keys, result['2022-08-01'].keys
  end
end
