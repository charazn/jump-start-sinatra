require 'sinatra'
# require 'sinatra/flash' #Did not work
require 'sinatra/reloader' if development?
require 'sass'
# require 'data_mapper'
require 'slim'
require 'securerandom'
# require 'dotenv' #Did not work
require './song'

# Dotenv.load #Did not work

configure :development do #Error: undefined method `configure' for main:Object (NoMethodError)
#With this commented, the authentication works!
  DataMapper::Logger.new($stdout, :debug)
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  # DataMapper.auto_upgrade! #For application wide use
  set :email_address => 'smtp.gmail.com',
      :email_user_name => ENV['GMAIL_USERNAME'],
      :email_password => ENV['GMAIL_PASSWORD'],
      :email_domain => 'localhost.localdomain'
end

configure :production do
  DataMapper::setup(:default, ENV['DATABASE_URL'])
  set :email_address => 'smtp.sendgrid.net',
      :email_user_name => ENV['SENDGRID_USERNAME'],
      :email_password => ENV['SENDGRID_PASSWORD'],
      :email_domain => 'heroku.com'
end

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(4)
  set :username, 'frank'
  set :password, 'sinatra'
end

#I find somewhat unnecessary because @title still must be set in each route handler
before do
  set_title
end

helpers do
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

  def send_message
    Pony.mail(
      :from => params[:name] + "<" + params[:email] + ">",
      :to => "charazn37@gmail.com",
      :subject => params[:name] + " has contacted you",
      :body => params[:message],
      :port => '587',
      :via => :smtp,
      :via_options => {
        :address => 'smtp.gmail.com',
        :port => '587',
        :enable_starttls_auto => true,
        :user_name => 'charazn37',
        :password => ENV['GMAIL'],
        :authentication => :plain,
        :domain => 'localhost.localdomain'
      }
    )
  end
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
  @title = "Contact Us"
  slim :contact
end

post '/contact' do
  send_message
  flash[:notice] = "Thank you for your message. We'll be in touch soon."
  redirect to('/')
end

get '/fake-error' do
  status 500
  "There's nothing wrong, really."
end

get '/login' do
  @title = "Login Page"
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
  @title = "All Sinatra's Songs"
  @songs = Song.all
  slim :songs
end

post '/songs' do
  song = Song.create(params[:song])
  # flash[:notice] = "Song successfully added" if song = Song.create(params[:song])
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
  # protected!
  halt(401, 'Not Authorized User') unless session[:admin]
  song = Song.get(params[:id])
  song.update(params[:song])
  # if song.update(params[:song])
  #   flash[:notice] = "Song successfully updated"
  # end
  redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
  halt(401, 'Not Authorized User') unless session[:admin]
  Song.get(params[:id]).destroy
  # if Song.get(params[:id]).destroy
  #   flash[:notice] = "Song deleted"
  # end
  redirect to('/songs')
end
