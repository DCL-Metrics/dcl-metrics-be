if ENV['RACK_ENV'] == 'test' || ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load
end

require 'logger'
system "bundle exec irb -I. -r lib/main.rb"
