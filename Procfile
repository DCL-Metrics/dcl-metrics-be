release: bundle exec rake heroku:release
web: bundle exec puma -R config.ru -p ${PORT:-3000} -e ${RACK_ENV}
worker: bundle exec sidekiq -r ./lib/main.rb -e ${RACK_ENV} -c 3
