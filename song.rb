require 'dm-core'
require 'dm-migrations'

class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :lyrics, Text
  property :length, Integer
  property :released_on, Date
  property :likes, Integer, :default => 0
end

DataMapper.finalize

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

  helpers SongHelpers

  configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  end

  configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
  end

  get '/' do
    @title = "All Sinatra's Songs"
    find_songs
    slim :songs
  end

  post '/' do
    flash[:notice] = "Song successfully added" if create_song
    redirect to("/#{@song.id}")
  end

  get '/new' do
    @song = Song.new
    slim :new_song
  end

  get '/:id' do
    @song = find_song
    slim :show_song
  end

  get '/:id/edit' do
    protected!
    @song = find_song
    slim :edit_song
  end

  put '/:id' do
    protected!
    song = find_song
    if song.update(params[:song])
      flash[:notice] = "Song successfully updated"
    end
    redirect to("/#{song.id}")
  end

  delete '/:id' do
    protected!
    if find_song.destroy
      flash[:notice] = "Song deleted"
    end
    redirect to('/')
  end

  post '/:id/like' do
    @song = find_song
    @song.likes = @song.likes.next
    @song.save
    redirect to("/#{@song.id}") unless request.xhr?
    slim :like, :layout => false
  end
end
