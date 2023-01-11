require './spec/spec_helper'

class DailyParcelStatsSpec < BaseSpec
  before do
    create_data_points

    # process user activity on day one
    Services::DailyUserActivityBuilder.call(date: day_one)

    peer_stats_params = Models::DataPoint.
      where(date: day_one).
      map { |x| { coordinates: x.coordinates, cid: x.scene_cid } }.
      uniq

    create_peer_stats(day_one, peer_stats_params)
    create_parcel_traffic(day_one)

    # process user activity on day two
    Services::DailyUserActivityBuilder.call(date: day_two)

    peer_stats_params = Models::DataPoint.
      where(date: day_two).
      map { |x| { coordinates: x.coordinates, cid: x.scene_cid } }.
      uniq

    create_peer_stats(day_two, peer_stats_params)
    create_parcel_traffic(day_two)
  end

  # two fully afk sessions - one on day one, one on day two
  let(:address_one) { '0x1d22d0041d6d9e7ec6865ca06292af8d5fb050b0' }

  # one session across multiple parcels starting on day one and ending on day two
  let(:address_two) { '0xabc2d0041d6d9e7ec6865ca06292af8d5fb0abcd' }

  let(:day_one) { '2022-04-10' }
  let(:day_one_coordinates) { ['20,24', '20,25', '20,23', '120,-25'].sort }

  let(:day_two) { '2022-04-11' }
  let(:day_two_coordinates) { ['22,25', '12,-5'].sort }

  it 'processes data with expected flow and results' do

    # build daily parcel stats for day one
    Services::DailyParcelStatsBuilder.call(date: day_one)

    assert_equal 4, Models::DailyParcelStats.count

    # build daily stats for day two
    Services::DailyParcelStatsBuilder.call(date: day_two)

    assert_equal 6, Models::DailyParcelStats.count

    day_one_stats = Models::DailyParcelStats.where(date: day_one).sort_by(&:coordinates)
    assert_equal 4, day_one_stats.count
    assert_equal day_one_coordinates, day_one_stats.map(&:coordinates).sort
    assert_equal [120, 180, 440, 720], day_one_stats.map(&:avg_time_spent).sort
    assert_equal [0, 0, 0, 720], day_one_stats.map(&:avg_time_spent_afk).sort
    assert_equal [1, 1, 1, 1], day_one_stats.map(&:unique_visitors).sort

    assert_equal '120,-25', day_one_stats.first.coordinates
    assert_equal 720, day_one_stats.first.avg_time_spent
    assert_equal 720, day_one_stats.first.avg_time_spent_afk
    assert_equal 1, day_one_stats.first.unique_visitors
    assert_equal 1, day_one_stats.first.logins
    assert_equal 1, day_one_stats.first.logouts

    day_two_stats = Models::DailyParcelStats.where(date: day_two)
    assert_equal 2, day_two_stats.count
    assert_equal day_two_coordinates, day_two_stats.map(&:coordinates).sort
    assert_equal [1, 900], day_two_stats.map(&:avg_time_spent).sort
    assert_equal [0, 900], day_two_stats.map(&:avg_time_spent_afk).sort
    assert_equal [1, 1], day_two_stats.map(&:unique_visitors).sort

    assert_equal '12,-5', day_two_stats.last.coordinates
    assert_equal 900, day_two_stats.last.avg_time_spent
    assert_equal 900, day_two_stats.last.avg_time_spent_afk
    assert_equal 1, day_two_stats.last.unique_visitors
    assert_equal 1, day_two_stats.last.logins
    assert_equal 1, day_two_stats.last.logouts
  end
end
