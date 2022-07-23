class DailyParcelStatsSpec < BaseSpec
  before { create_data_points }

  # two fully afk sessions - one on day one, one on day two
  let(:address_one) { '0x1d22d0041d6d9e7ec6865ca06292af8d5fb050b0' }

  # one session across multiple parcels starting on day one and ending on day two
  let(:address_two) { '0xabc2d0041d6d9e7ec6865ca06292af8d5fb0abcd' }

  let(:day_one) { '2022-04-10' }
  let(:day_two) { '2022-04-11' }

  it 'processes data with expected flow and results' do
    # process parcel activity on day one
    # print "\n\nDay one\n\n"
    Services::DailyUserActivityBuilder.call(date: day_one)

    # build daily parcel stats for day one
    Services::DailyParcelStatsBuilder.call(date: day_one)

    assert_equal 4, Models::DailyParcelStats.count

    # process parcel activity on day two
    Services::DailyUserActivityBuilder.call(date: day_two)

    # build daily stats for day two
    Services::DailyParcelStatsBuilder.call(date: day_two)

    assert_equal 6, Models::DailyParcelStats.count

    # process daily stats for day one again
    # they should be updated since there are more user activities
    Services::DailyParcelStatsBuilder.call(date: day_one)

    # additional stats are present
    assert_equal 7, Models::DailyParcelStats.count

    day_one_stats = Models::DailyParcelStats.where(date: day_one)
    assert_equal 5, day_one_stats.count

    assert_equal '120,-25', day_one_stats.first.coordinates
    assert_equal 720, day_one_stats.first.avg_time_spent
    assert_equal 720, day_one_stats.first.avg_time_spent_afk
    assert_equal 1, day_one_stats.first.unique_visitors
    assert_equal 1, day_one_stats.first.logins
    assert_equal 1, day_one_stats.first.logouts

    day_two_stats = Models::DailyParcelStats.where(date: day_two)
    assert_equal 2, day_two_stats.count

    assert_equal '12,-5', day_two_stats.first.coordinates
    assert_equal 900, day_two_stats.first.avg_time_spent
    assert_equal 900, day_two_stats.first.avg_time_spent_afk
    assert_equal 1, day_two_stats.first.unique_visitors
    assert_equal 1, day_two_stats.first.logins
    assert_equal 1, day_two_stats.first.logouts
  end
end
