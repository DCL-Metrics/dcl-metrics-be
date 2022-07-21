class DailyStatsSpec < BaseSpec
  before do
    # insert known data into db
    Dir.glob('./spec/fixtures/data_points/*.csv') do |filename|
      data = CSV.parse(File.read(filename), headers: true)

      data.each do |row|

        Models::DataPoint.create(
          address: row['address'],
          coordinates: row['coordinates'],
          date: row['date'],
          peer_id: row['peer_id'],
          position: row['position'],
          timestamp: row['timestamp']
        )
      end
    end
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

    # process user activity on day two
    Services::DailyUserActivityBuilder.call(date: day_two)

    # build daily stats for day two
    Services::DailyStatsBuilder.call(date: day_two)

    day_two_stats = Models::DailyStats.last
    assert_equal 2, day_two_stats.unique_users
    assert_equal 2, day_two_stats.total_active_parcels
  end
end
