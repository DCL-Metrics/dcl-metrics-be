class DailyUserStatsSpec < BaseSpec
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

    # build daily user stats for day one
    Services::DailyUserStatsBuilder.call(date: day_one)

    assert_equal 3, Models::DailyUserStats.count

    top_visits = Models::DailyUserStats.
      where(date: day_one).
      exclude(parcels_visited: nil).
      order(Sequel.desc(:parcels_visited)).
      all

    assert_equal 2, top_visits.count
    assert_equal address_two, top_visits[0].address
    assert_equal 3, top_visits[0].parcels_visited

    top_time_spent = Models::DailyUserStats.
      where(date: day_one).
      exclude(time_spent: nil).
      order(Sequel.desc(:time_spent)).
      all

    assert_equal 1, top_time_spent.count
    assert_equal address_one, top_time_spent[0].address
    assert_equal 720, top_time_spent[0].time_spent

    # process user activity on day two
    Services::DailyUserActivityBuilder.call(date: day_two)

    # build daily stats for day two
    Services::DailyUserStatsBuilder.call(date: day_two)

    assert_equal 6, Models::DailyUserStats.count

    top_visits = Models::DailyUserStats.
      where(date: day_two).
      exclude(parcels_visited: nil).
      order(Sequel.desc(:parcels_visited)).
      all

    assert_equal 2, top_visits.count

    top_time_spent = Models::DailyUserStats.
      where(date: day_two).
      exclude(time_spent: nil).
      order(Sequel.desc(:time_spent)).
      all

    assert_equal 1, top_time_spent.count
    assert_equal address_one, top_time_spent[0].address
    assert_equal 900, top_time_spent[0].time_spent


    # process daily stats for day one again
    # they should be updated since there are more user activities
    Services::DailyUserStatsBuilder.call(date: day_one)

    # an additional stat is present
    assert_equal 7, Models::DailyUserStats.count

    top_visits = Models::DailyUserStats.
      where(date: day_one).
      exclude(parcels_visited: nil).
      order(Sequel.desc(:parcels_visited)).
      all

    assert_equal 2, top_visits.count
    assert_equal address_two, top_visits[0].address
    assert_equal 3, top_visits[0].parcels_visited

    top_time_spent = Models::DailyUserStats.
      where(date: day_one).
      exclude(time_spent: nil).
      order(Sequel.desc(:time_spent)).
      all

    # now both sessions are present and
    # address two actually had a longer session
    assert_equal 2, top_time_spent.count
    assert_equal address_two, top_time_spent[0].address
    assert_equal 740, top_time_spent[0].time_spent
  end
end
