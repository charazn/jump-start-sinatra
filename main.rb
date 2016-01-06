require 'sass'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'

get '/application.css' do
  scss :application
end

not_found do
  slim :not_found
end

get '/' do
  slim :home
end

get '/about' do
  @title = "All About This Website"
  slim :about
end

get '/contact' do
  slim :contact
end

get '/fake-error' do
  status 500
  "There's nothing wrong, really."
end
