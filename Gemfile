source 'https://www.rubygems.org'

gem 'rake'
gem 'sinatra'

# database
gem 'sequel'
gem 'pg'

# background jobs
gem 'sidekiq'

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

