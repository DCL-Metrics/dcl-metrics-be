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

if ENV['SENTRY_DSN']
  require 'sentry-ruby'

  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:sentry_logger, :http_logger]
    config.traces_sample_rate = ENV['SENTRY_SAMPLE_RATE']

    config.before_send = lambda do |event, hint|
      Services::TelegramOperator.notify(
        level: :error,
        message: "Sentry caught an error",
        payload: hint
      )

      event
    end
  end

  # use Sentry::Rack::CaptureExceptions
end

run Server
