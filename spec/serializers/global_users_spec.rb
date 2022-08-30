class GlobalUsersSpec < BaseSpec
  before do
    create_daily_user_stats(data)
    Timecop.freeze(Time.utc(2022, 8, 27, 12))
  end

  after do
    Timecop.return
  end

  let(:data) { JSON.parse(File.read('./spec/fixtures/daily_user_stats/7d.json')) }

  let(:user_data) do
    JSON.
      parse(File.read('./spec/fixtures/user_data.json')).
      map(&:symbolize_keys)
  end

  let(:expected) do
    JSON.
      parse(File.read('./spec/fixtures/expectations/serializers/global_users.json')).
      symbolize_keys
  end

  let(:expected_parcels_visted_keys) do
    %i[address parcels_visited avatar_url guest_user name verified_user]
  end

  let(:expected_time_spent_keys) do
    %i[address time_spent avatar_url guest_user name verified_user]
  end

  it 'serializes data and returns expected output' do
    Services::FetchDclUserData.stub(:call, user_data) do
      result = Serializers::Global::Users.serialize

      # ensure all the nodes are there
      assert_equal expected.keys, result.keys

      # ensure the nodes come out as expected
      assert_equal expected[:yesterday],  result[:yesterday]
      assert_equal expected[:last_week],  result[:last_week]
      assert_equal expected[:last_month], result[:last_week] # there's only 7d of data

      # ensure the format is as expected
      yesterday = result[:yesterday]
      assert_equal %i[parcels_visited time_spent], result[:yesterday].keys
      assert_equal expected_parcels_visted_keys, yesterday[:parcels_visited][0].keys
      assert_equal expected_time_spent_keys, yesterday[:time_spent][0].keys
    end
  end
end
