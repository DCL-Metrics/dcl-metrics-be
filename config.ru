if ENV['RACK_ENV'] == 'test' || ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load

  require 'pry'
end

require 'rubygems'
require 'bundler/setup'
require 'json'

Bundler.require

require './lib/main'
require './server'

# use Sentry::Rack::CaptureExceptions
run Server
