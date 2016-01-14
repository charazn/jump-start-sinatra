require 'sinatra/base'

require './application'
require './main'
require './song'

map '/' do
  run Website
end

map '/songs' do
  run SongController
end
