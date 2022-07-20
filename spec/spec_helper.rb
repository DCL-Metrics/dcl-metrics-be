ENV['RACK_ENV'] = 'test'
ENV['APP_ENV'] = 'test'

require 'dotenv'
Dotenv.load(File.expand_path('../../.env.test', __FILE__))

require 'bundler'
Bundler.require

# require testing components
require 'rack/test'
require 'minitest/autorun'
require 'pry'

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

  def expand_path(path)
    File.expand_path(path, __FILE__)
  end
end
