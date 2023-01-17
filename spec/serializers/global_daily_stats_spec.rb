require './spec/spec_helper'

class GlobalDailyStatsSpec < BaseSpec
  before do
    create_daily_stats(data)
    Timecop.freeze(Time.utc(2023, 1, 07, 12))
  end

  after do
    Timecop.return
  end

  let(:data) { parse_json_fixture('daily_stats/30d.json') }

  let(:expected) do
    parse_json_fixture('expectations/serializers/global_daily_stats.json')
  end

  let(:expected_keys) { %i[active_parcels active_scenes users degraded] }

  it 'serializes data and returns expected output' do
    result = Serializers::Global::DailyStats.serialize

    # ensure all the nodes are there
    assert_equal expected.keys.count, result.keys.count

    # ensure the nodes come out as expected
    assert_equal expected, result.stringify_keys

    # ensure the format is as expected
    assert_equal expected_keys, result['2023-01-01'].keys
  end
end
