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

require 'sentry-ruby'

if ENV['SENTRY_DSN']
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:sentry_logger, :http_logger]
    config.traces_sample_rate = ENV['SENTRY_SAMPLE_RATE']

    config.before_send = lambda do |event, hint|
      p event: event
      p hint: hint

      # Services::TelegramOperator.notify(
      #   level: :error,
      #   message: "Sentry caught an error",
      #   payload: hint
      # )
    end
  end
end

use Sentry::Rack::CaptureExceptions


Sentry.capture_message("test message")

run Server
