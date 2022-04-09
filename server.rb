require 'sinatra'

class Server < Sinatra::Application
  get '/' do
    status 200
    'ok'
  end
end
