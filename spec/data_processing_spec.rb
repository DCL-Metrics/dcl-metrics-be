require 'spec_helper'
require 'csv'

class DataProcessingSpec < BaseSpec
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

    user_one_activities = Models::UserActivity.where(address: address_one)
    assert_equal 5, Models::UserActivity.count

    user_one_activities = Models::UserActivity.where(address: address_one)
    assert_equal 3, user_one_activities.count
    assert_equal ['afk', 'session', 'visit'], user_one_activities.map(&:name).sort

    session = user_one_activities.detect { |a| a.name == 'session' }
    assert_equal 720, session.duration
    assert_equal '120,-25', session.starting_coordinates
    assert_equal '120,-25', session.ending_coordinates

    afk = user_one_activities.detect { |a| a.name == 'afk' }
    assert_equal 720, afk.duration
    assert_equal '120,-25', afk.starting_coordinates
    assert_equal '120,-25', afk.ending_coordinates

    user_two_activities = Models::UserActivity.where(address: address_two)
    assert_equal 2, user_two_activities.count
    assert_equal ['visit'], user_two_activities.map(&:name).uniq

    # process user activity on day two
    # print "\n\nDay two\n\n"
    Services::DailyUserActivityBuilder.call(date: day_two)

    assert_equal 11, Models::UserActivity.count

    user_one_activities = Models::UserActivity.where(address: address_one)
    assert_equal 6, user_one_activities.count
    assert_equal ['afk', 'session', 'visit'], user_one_activities.map(&:name).uniq.sort

    session = user_one_activities.all.select { |a| a.name == 'session' }.last
    assert_equal 900, session.duration
    assert_equal '12,-5', session.starting_coordinates
    assert_equal '12,-5', session.ending_coordinates

    afk = user_one_activities.all.select { |a| a.name == 'afk' }.last
    assert_equal 900, afk.duration
    assert_equal '12,-5', afk.starting_coordinates
    assert_equal '12,-5', afk.ending_coordinates

    user_two_activities = Models::UserActivity.where(address: address_two)
    assert_equal 5, user_two_activities.count
    assert_equal ['session', 'visit'], user_two_activities.map(&:name).uniq.sort
  end

  # process user tags

  # process location tags
end
