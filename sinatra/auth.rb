require 'sinatra/base'
require 'sinatra/flash' #Cannot load #Can load after change to 'sinatra/base'

module Sinatra
  module Auth
    module Helpers
      def authorized?
        puts ">>> authorized? #{session[:admin]}"
        session[:admin]
      end

      def protected!
        halt 401, slim(:unauthorized) unless authorized?
      end
    end

    def self.registered(app)
      app.helpers Helpers

      app.enable :sessions
      #Note :session_secret cannot be placed here as it will interfere with the enable :sessions
      # app.set :session_secret, SecureRandom.hex(4) #Moved from main.rb

      app.set :username => 'frank',
              :password => 'sinatra'

      app.get '/login' do
        @title = "Login Page"
        slim :login
      end

      app.post '/login' do
        puts "Logging in... before username password check"
        if params[:username] == settings.username && params[:password] == settings.password
          session[:admin] = true
          flash[:notice] = "You are logged in as #{settings.username}"
          puts "Should log in >> #{session[:admin]}"
          redirect to('/songs')
        else
          flash[:notice] = "The username or password you entered is incorrect"
          puts "Failed to login"
          redirect to('/login')
        end
      end

      app.get '/logout' do
        session[:admin] = nil
        # session.clear
        flash[:notice] = "You have now logged out"
        redirect to('/')
      end
    end
  end
  register Auth
end
