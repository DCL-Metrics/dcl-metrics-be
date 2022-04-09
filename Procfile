release: bundle exec rake heroku:release
web: bundle exec puma -R config.ru -p ${PORT:-3000} -e ${RACK_ENV}
