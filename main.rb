# require 'sinatra/base' #From 'sinatra'
# require 'slim'
# require 'sass'
# require 'sinatra/flash' #Cannot load, #Can load after changing to 'sinatra/base'
# require 'sinatra/reloader' #if development? #Cannot load after chaning to 'sinatra/base' #Now can load
require 'pony' #Cannot load #Can load after changing to 'sinatra/base'
# require './sinatra/auth'
require 'v8'
require 'coffee-script'
# require 'data_mapper'
require 'securerandom'
require 'dotenv' #Cannot load #Now can load
# require './song' #Removed when making the app modular
require_relative 'asset_handler' #Same as require './asset_handler'

Dotenv.load #Now can load

class Website < ApplicationController
  # register Sinatra::Flash #Inherit from ApplicationController
  # register Sinatra::Auth #Inherit from ApplicationController

  use AssetHandler

  #Have to comment this out so that only one session is working in sinatra/auth
  # configure do
  #   enable :sessions #Set in sinatra/auth #Reenabled when making app modular
  #   set :session_secret, SecureRandom.hex(4)
  #   set :username, 'frank' #Set in sinatra/auth
  #   set :password, 'sinatra' #Set in sinatra/auth
  # end

  ### The email settings in both development and configure blocks did not affect the Pony mail settings which it should.
  ### To read more Sinatra documentation on this.
  # configure :development do #Error: undefined method `configure' for main:Object (NoMethodError)
  # #With this commented, the authentication works!
  #   # DataMapper::Logger.new($stdout, :debug) #Removed when making app modular, placed in SongController class
  #   # DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/development.db") #Removed when making app modular, placed in SongController class
  #   # DataMapper.auto_upgrade! #For application wide use
  #   set :email_address => 'smtp.gmail.com',
  #       :email_user_name => ENV['GMAIL_USERNAME'],
  #       :email_password => ENV['GMAIL_PASSWORD'],
  #       :email_domain => 'localhost.localdomain'
  # end

  # configure :production do
  #   # DataMapper::setup(:default, ENV['DATABASE_URL']) #Removed when making app modular, placed in SongController class
  #   set :email_address => 'smtp.sendgrid.net',
  #       :email_user_name => ENV['SENDGRID_USERNAME'],
  #       :email_password => ENV['SENDGRID_PASSWORD'],
  #       :email_domain => 'heroku.com'
  # end

  #I find this somewhat unnecessary because @title still must be set in each route handler
  before do
    set_title
  end

  # helpers do #Removed when making app modular
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
      # :port => '587',
      :via => :smtp,
      :via_options => {
        :address => 'smtp.sendgrid.net',
        :port => '587',
        :domain => 'heroku.com',
        :user_name => ENV['SENDGRID_USERNAME'],
        :password => ENV['SENDGRID_PASSWORD'],
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    )
  end
  # end

  #Moved to asset_handler.rb
  # get '/application.css' do
  #   scss :application
  # end

  # get '/javascripts/application.js' do
  #   coffee :application
  # end

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

  # get '/fake-error' do
  #   status 500
  #   "There's nothing wrong, really."
  # end
end
