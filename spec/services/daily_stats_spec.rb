require './spec/spec_helper'

class DailyStatsSpec < BaseSpec
  before do
    create_random_peer_stats(day_one, 6) # for total active parcels count
    create_random_peer_stats(day_two, 3) # for total active parcels count
    create_data_points                    # for unique users count
    create_scenes                         # for total active scenes count
  end

  # two fully afk sessions - one on day one, one on day two
  let(:address_one) { '0x1d22d0041d6d9e7ec6865ca06292af8d5fb050b0' }

  # one session across multiple parcels starting on day one and ending on day two
  let(:address_two) { '0xabc2d0041d6d9e7ec6865ca06292af8d5fb0abcd' }

  let(:day_one) { '2022-04-10' }
  let(:day_two) { '2022-04-11' }

  it 'processes data with expected flow and results' do
    # process user activity on day one
    # print "\n\nDay one\n\n"
    Services::DailyUserActivityBuilder.call(date: day_one)

    # build daily stats for day one
    Services::DailyStatsBuilder.call(date: day_one)

    assert_equal 1, Models::DailyStats.count

    day_one_stats = Models::DailyStats.first
    assert_equal 2, day_one_stats.unique_users
    assert_equal 4, day_one_stats.total_active_parcels
    assert_equal 0, day_one_stats.total_active_scenes

    # process user activity on day two
    Services::DailyUserActivityBuilder.call(date: day_two)

    # build daily stats for day two
    Services::DailyStatsBuilder.call(date: day_two)

    day_two_stats = Models::DailyStats.last
    assert_equal 2, day_two_stats.unique_users
    assert_equal 2, day_two_stats.total_active_parcels
    assert_equal 0, day_two_stats.total_active_scenes

    # LOW-PRIORITY TODO
    # process daily stats for day one again
    # they can be updated since there are more user activities
    # in this case not cause i didn't add that data but...
    # Services::DailyUserActivityBuilder.call(date: day_one)
  end
end
