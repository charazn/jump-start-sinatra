# require 'sinatra/base'
# require 'data_mapper' #Follow the book without using Datamapper
require 'dm-core'
require 'dm-migrations'
# require 'dm-timestamps'
# require 'slim'
# require 'sass'
# require 'sinatra/flash' #Can load after changing to 'sinatra/base'
# require 'sinatra/reloader'
# require './sinatra/auth'

#Moved to main.rb
# configure :development do #Error: undefined method `configure' for main:Object (NoMethodError)
#With this commented, the authentication works!
  # DataMapper::Logger.new($stdout, :debug)
  # DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  # DataMapper.auto_upgrade! #For application wide use
# end

class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :lyrics, Text
  property :length, Integer
  property :released_on, Date
  property :likes, Integer, :default => 0

  # def released_on=date
  #   super Date.parse(date) #Suggested to use Date.parse instead of Date.new!
  # end

  #After setting the default dateFormat in jquery to "yy-mm-dd" the string for the input is "yyyy-dd-mm"
  #Apparently this does not need to be set with a setter method for the database to know how to save,
  #read and display it in the proper format.
  # def released_on=date
  #   super Date.strptime(date, '%m/%d/%Y')
  # end
end

DataMapper.finalize
#Not use auto_migrate! which only creates a new table and wipes out existing data!
#Not put Song.auto_upgrade! here, because will be run each time song.rb loads.
#Do so in irb


#This module did not work. #Works after making SongController a separate class.
module SongHelpers
  def find_songs
    @songs = Song.all
  end

  def find_song
    @song = Song.get(params[:id])
  end

  def create_song
    @song = Song.create(params[:song])
  end
end


class SongController < ApplicationController
  enable :method_override
  # register Sinatra::Flash #Inherit from ApplicationController
  # register Sinatra::Auth #Inherit from ApplicationController

  helpers SongHelpers

  #Have to comment this out so that only one session is working in sinatra/auth
  # configure do
  #   enable :sessions
  #   set :username, 'frank'
  #   set :password, 'sinatra'
  # end

  configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  end

  configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
  end

  before do
    set_title
  end

  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end

  def current_path?(path = '/')
    (request.path == path || request.path == path + '/') ? "current" : nil
  end

  def set_title
    @title ||= "Songs By Sinatra"
  end

  get '/' do
    @title = "All Sinatra's Songs"
    # puts ">>>> /songs >> #{session[:admin]}" #When debugging for the lost session[:admin]
    # @songs = Song.all
    find_songs
    slim :songs
  end

  post '/' do
    # song = Song.create(params[:song])
    # song = Song.new(params[song])
    # if song.errors.empty?
    # create_song
    flash[:notice] = "Song successfully added" if create_song #song = Song.create(params[:song])
    redirect to("/#{@song.id}")
  end

  get '/new' do
    # @song = Song.new
    @song = Song.new
    slim :new_song
  end

  get '/:id' do
    # @song = Song.get(params[:id])
    @song = find_song
    slim :show_song
  end

  get '/:id/edit' do
    protected!
    # @song = Song.get(params[:id])
    @song = find_song
    slim :edit_song
  end

  put '/:id' do
    protected!
    # song = Song.get(params[:id])
    song = find_song
    if song.update(params[:song])
      flash[:notice] = "Song successfully updated"
    end
    redirect to("/#{song.id}")
  end

  delete '/:id' do
    protected!
    # Song.get(params[:id]).destroy
    if find_song.destroy
      flash[:notice] = "Song deleted"
    end
    redirect to('/')
  end

  post '/:id/like' do
    # @song = Song.get(params[:id])
    @song = find_song
    @song.likes = @song.likes.next
    @song.save
    # redirect back
    redirect to("/#{@song.id}") unless request.xhr?
    slim :like, :layout => false
  end
end
