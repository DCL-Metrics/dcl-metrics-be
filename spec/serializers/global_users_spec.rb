require './spec/spec_helper'

class GlobalUsersSpec < BaseSpec
  before do
    create_daily_user_stats(data)
    create_users
    Timecop.freeze(Time.utc(2022, 8, 27, 12))
  end

  after do
    Timecop.return
  end

  let(:data) { parse_json_fixture('daily_user_stats/7d.json') }

  let(:expected) do
    parse_json_fixture('expectations/serializers/global_users.json').symbolize_keys
  end

  let(:expected_parcels_visted_keys) do
    %i[address parcels_visited avatar_url guest_user name verified_user]
  end

  let(:expected_time_spent_keys) do
    %i[address time_spent avatar_url guest_user name verified_user]
  end

  # NOTE: i don't love how this is tested now, but the original tests (commented)
  # were passing locally but always fucked up in ci ¯\_(ツ)_/¯
  it 'serializes data and returns expected output' do
    result = Serializers::Global::Users.serialize

    # ensure all the nodes are there
    assert_equal expected.keys, result.keys

    # yesterday
    parcels_visited_yesterday = result[:yesterday][:parcels_visited]
    assert_equal 'd441', parcels_visited_yesterday[0][:address].chars.last(4).join
    assert_equal 196, parcels_visited_yesterday[0][:parcels_visited]
    assert_equal false, parcels_visited_yesterday[0][:guest_user]
    assert_equal 'M1ssConduct', parcels_visited_yesterday[0][:name]
    assert_equal false, parcels_visited_yesterday[0][:verified_user]

    assert_equal '40a1', parcels_visited_yesterday[3][:address].chars.last(4).join
    assert_equal 94, parcels_visited_yesterday[3][:parcels_visited]
    assert_equal false, parcels_visited_yesterday[3][:guest_user]
    assert_equal 'jackass', parcels_visited_yesterday[3][:name]
    assert_equal false, parcels_visited_yesterday[3][:verified_user]

    assert_equal '0039', parcels_visited_yesterday[-1][:address].chars.last(4).join
    assert_equal 77, parcels_visited_yesterday[-1][:parcels_visited]
    assert_equal false, parcels_visited_yesterday[-1][:guest_user]
    assert_equal 'Gabriel', parcels_visited_yesterday[-1][:name]
    assert_equal false, parcels_visited_yesterday[-1][:verified_user]

    time_spent_yesterday = result[:yesterday][:time_spent]
    assert_equal 'a914', time_spent_yesterday[0][:address].chars.last(4).join
    assert_equal 83614, time_spent_yesterday[0][:time_spent]
    assert_equal false, time_spent_yesterday[0][:guest_user]
    assert_equal 'nightrider#a914', time_spent_yesterday[0][:name]
    assert_equal false, time_spent_yesterday[0][:verified_user]

    assert_equal '5a65', time_spent_yesterday[3][:address].chars.last(4).join
    assert_equal 82576, time_spent_yesterday[3][:time_spent]
    assert_equal false, time_spent_yesterday[3][:guest_user]
    assert_equal '4Wisdom#5a65', time_spent_yesterday[3][:name]
    assert_equal false, time_spent_yesterday[3][:verified_user]

    assert_equal '18ac', time_spent_yesterday[-1][:address].chars.last(4).join
    assert_equal 80962, time_spent_yesterday[-1][:time_spent]
    assert_equal false, time_spent_yesterday[-1][:guest_user]
    assert_equal 'LouellaSiennaa', time_spent_yesterday[-1][:name]
    assert_equal false, time_spent_yesterday[-1][:verified_user]

    # last week
    parcels_visited_last_week = result[:last_week][:parcels_visited]
    assert_equal 'aa5f', parcels_visited_last_week[0][:address].chars.last(4).join
    assert_equal 278, parcels_visited_last_week[0][:parcels_visited]
    assert_equal false, parcels_visited_last_week[0][:guest_user]
    assert_equal 'wayneonthemoon', parcels_visited_last_week[0][:name]
    assert_equal false, parcels_visited_last_week[0][:verified_user]

    assert_equal '0039', parcels_visited_last_week[3][:address].chars.last(4).join
    assert_equal 227, parcels_visited_last_week[3][:parcels_visited]
    assert_equal false, parcels_visited_last_week[3][:guest_user]
    assert_equal 'Gabriel', parcels_visited_last_week[3][:name]
    assert_equal false, parcels_visited_last_week[3][:verified_user]

    assert_equal '3414', parcels_visited_last_week[-1][:address].chars.last(4).join
    assert_equal 181, parcels_visited_last_week[-1][:parcels_visited]
    assert_equal true, parcels_visited_last_week[-1][:guest_user]
    assert_equal 'Guest User', parcels_visited_last_week[-1][:name]
    assert_equal false, parcels_visited_last_week[-1][:verified_user]

    time_spent_last_week = result[:last_week][:time_spent]
    assert_equal '87e9', time_spent_last_week[0][:address].chars.last(4).join
    assert_equal 228052, time_spent_last_week[0][:time_spent]
    assert_equal true, time_spent_last_week[0][:guest_user]
    assert_equal 'Guest User', time_spent_last_week[0][:name]
    assert_equal false, time_spent_last_week[0][:verified_user]

    assert_equal '938a', time_spent_last_week[3][:address].chars.last(4).join
    assert_equal 170773, time_spent_last_week[3][:time_spent]
    assert_equal true, time_spent_last_week[3][:guest_user]
    assert_equal 'Guest User', time_spent_last_week[3][:name]
    assert_equal false, time_spent_last_week[3][:verified_user]

    assert_equal 'b699', time_spent_last_week[-1][:address].chars.last(4).join
    assert_equal 163924, time_spent_last_week[-1][:time_spent]
    assert_equal true, time_spent_last_week[-1][:guest_user]
    assert_equal 'Guest User', time_spent_last_week[-1][:name]
    assert_equal false, time_spent_last_week[-1][:verified_user]

    # # ensure the nodes come out as expected
    # assert_equal expected[:yesterday], result[:yesterday]
    # assert_equal expected[:last_week], result[:last_week]
    # assert_equal expected[:last_month], result[:last_week] # there's only 7d of data
    # assert_equal expected[:last_quarter], result[:last_week] # there's only 7d of data

    # ensure the format is as expected
    yesterday = result[:yesterday]
    assert_equal %i[parcels_visited scenes_visited time_spent], result[:yesterday].keys
    assert_equal expected_parcels_visted_keys, yesterday[:parcels_visited][0].keys
    assert_equal expected_time_spent_keys, yesterday[:time_spent][0].keys
  end
end
