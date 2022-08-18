source 'https://www.rubygems.org'
ruby '3.1.2'

gem 'rake'
gem 'sinatra'

# database
gem 'sequel'
gem 'pg'

# background jobs
gem 'sidekiq'

# http
gem 'faraday'

# bug-tracking and performance monitoring
gem "sentry-ruby"

group :production do
  gem 'puma'
end

group :development, :test do
  gem 'dotenv'
  gem 'pry'
end

group :development do
  gem 'rerun'
  gem 'foreman'
end

group :test do
  gem 'rack-test'
  gem 'minitest'
end

