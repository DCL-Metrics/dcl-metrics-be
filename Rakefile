require 'rake/testtask'

# load environment files if running locally
if ENV['RACK_ENV'] == 'test' || ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load(
    File.expand_path("../.env.#{ENV['RACK_ENV']}", __FILE__),
    File.expand_path('../.env', __FILE__),)
end

namespace :heroku do
  desc "run tasks on application release"
  task :release do
    `bundle exec rake db:migrate`
  end
end

namespace :dcl do
  desc "fetch peers"
  task :fetch_peers do
    require './lib/main'

    4.times do |i|
      raw_data = `curl https://peer.decentraland.org/comms/peers`
      data = JSON.parse(raw_data)

      Models::PeersDump.create(data_json: data['peers'].to_json) if data['ok']
      sleep 150 unless i == 3
    end
  end
end

namespace :db do
  APP_NAME = 'dclund'

  desc "Drop database for environment in DATABASE_ENV for DATABASE_USER"
  task :drop do
    unless ENV.member?('DATABASE_ENV')
      raise 'Please provide the environment to create for as `ENV[DATABASE_ENV]`'
    end

    env = ENV['DATABASE_ENV']
    user = ENV['DATABASE_USER']

    `dropdb -U #{user} #{APP_NAME}-#{env}`
    print "Database #{APP_NAME}-#{env} dropped successfully\n"
  end

  desc "Create database for environment in DATABASE_ENV for DATABASE_USER"
  task :create do
    unless ENV.member?('DATABASE_ENV')
      raise 'Please provide the environment to create for as `ENV[DATABASE_ENV]`'
    end

    env = ENV['DATABASE_ENV']
    user = ENV['DATABASE_USER']

    `createdb -p 5432 -U #{user} #{APP_NAME}-#{env}`
    print "Database #{APP_NAME}-#{env} created successfully\n"
  end

  desc "Run migrations (optionally include version number)"
  task :migrate do
    require "sequel"
    Sequel.extension :migration

    # NOTE: example format:
    # DATABASE_URL=postgres://{user}:{password}@{hostname}:{port}/{database-name}
    unless ENV.member?('DATABASE_URL')
      raise 'Please provide a database as `ENV[DATABASE_URL]`'
    end

    version = ENV['VERSION']
    database_url = ENV['DATABASE_URL']
    migration_dir = File.expand_path('../migrations', __FILE__)
    db = Sequel.connect(database_url)

    if version
      puts "Migrating to version #{version}"
      Sequel::Migrator.run(db, migration_dir, :target => version.to_i)
    else
      puts "Running database migrations"
      Sequel::Migrator.run(db, migration_dir)
    end

    puts 'Migration complete'
  end

  desc "Drop, create and migrate DB"
  task :reset do
    return unless ENV['RACK_ENV'] == 'development'

    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end
end
