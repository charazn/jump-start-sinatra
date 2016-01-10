require 'data_mapper'

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
  # property :released_on, DateTime
  property :likes, Integer, :default => 0

  # def released_on=date
  #   super Date.parse(date) #Suggested to use Date.parse instead of Date.new!
  # end

  # def released_on=date
  #   super Date.strptime(date, '%m/%d/%Y')
  # end

  #This module did not work...
  # module SongHelpers
  #   def find_songs
  #     @songs = Song.all
  #   end

  #   def find_song
  #     @song = Song.get(params[:id])
  #   end

  #   def create_song
  #     @song = Song.create(params[:song])
  #   end
  # end

  # helpers SongHelpers
end

DataMapper.finalize


#Not use auto_migrate! which only creates a new table and wipes out existing data!
#Not put Song.auto_upgrade! here, because will be run each time song.rb loads.
#Do so in irb
