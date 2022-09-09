ENV['DATABASE_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'
ENV['APP_ENV'] = 'test'

require 'dotenv'
Dotenv.load(File.expand_path('../../.env.test', __FILE__))

require 'bundler'
Bundler.require

# require testing components
require 'rack/test'
require 'minitest/autorun'
require 'timecop'
require 'pry'

# require csv and json for fixtures
require 'json'
require 'csv'

# run sidekiq jobs immediately (skip the queue)
require "sidekiq/testing"
Sidekiq::Testing.inline!

# require application components
require './lib/main'

class BaseSpec < Minitest::Spec
  def setup
    # TRUNCATE ALL DB TABLES BEFORE EACH TEST RUN
    (DATABASE_CONNECTION.tables - [:schema_info, :schema_migrations]).each do |table|
      DATABASE_CONNECTION << "TRUNCATE #{table} CASCADE;"
    end
  end

  def create_peer_stats_on_date(date, count = 5)
    count.times do |i|
      Models::PeerStats.create(
        date: date,
        data_json: {}.to_json,
        coordinates: "#{Random.rand(150)},#{Random.rand(150)}"
      )
    end
  end

  def create_data_points
    Dir.glob('./spec/fixtures/data_points/*.csv') do |filename|
      data = CSV.parse(File.read(filename), headers: true)

      data.each do |row|
        Models::DataPoint.create(
          address: row['address'],
          coordinates: row['coordinates'],
          date: row['date'],
          peer_id: row['peer_id'],
          position: row['position'],
          timestamp: Time.parse(row['timestamp'])
        )
      end
    end
  end

  def create_daily_stats(data)
    data.each do |row|
      Models::DailyStats.
        create(row.except('id', 'created_at').symbolize_keys)
    end
  end

  def create_daily_user_stats(data)
    data.each do |row|
      Models::DailyUserStats.
        create(row.except('id', 'created_at').symbolize_keys)
    end
  end

  def create_daily_parcel_stats(data)
    data.each do |row|
      Models::DailyParcelStats.
        create(row.except('id', 'created_at').symbolize_keys)
    end
  end

  def expand_path(path)
    File.expand_path(path, __FILE__)
  end
end
