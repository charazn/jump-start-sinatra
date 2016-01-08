require './song'
require 'sass'
require 'sinatra'
require 'sinatra/reloader' if development?
# require 'data_mapper'
require 'slim'
require 'securerandom'

configure :development do #Error: undefined method `configure' for main:Object (NoMethodError)
#With this commented, the authentication works!
  DataMapper::Logger.new($stdout, :debug)
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  # DataMapper.auto_upgrade! #For application wide use
end

configure :production do
  DataMapper::setup(:default, ENV['DATABASE_URL'])
end

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(4)
  set :username, 'frank'
  set :password, 'sinatra'
end

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

get '/login' do
  slim :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to('/songs')
  else
    slim :login
  end
end

get '/logout' do
  session.clear
  redirect to('/login')
end

get '/songs' do
  @songs = Song.all
  slim :songs
end

post '/songs' do
  song = Song.create(params[:song])
  redirect to("/songs/#{song.id}")
end

get '/songs/new' do
  @song = Song.new
  slim :new_song
end

get '/songs/:id' do
  @song = Song.get(params[:id])
  slim :show_song
end

get '/songs/:id/edit' do
  halt(401, 'Not Authorized User') unless session[:admin]
  @song = Song.get(params[:id])
  slim :edit_song
end

put '/songs/:id' do
  halt(401, 'Not Authorized User') unless session[:admin]
  song = Song.get(params[:id])
  song.update(params[:song])
  redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
  halt(401, 'Not Authorized User') unless session[:admin]
  Song.get(params[:id]).destroy
  redirect to('/songs')
end
