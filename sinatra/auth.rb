require 'sinatra/base'
# require 'sinatra/flash' #Cannot load

module Sinatra
  module Auth
    module Helpers
      def authorized?
        session[:admin]
      end

      def protected!
        halt 401, slim(:unauthorized) unless authorized?
      end
    end

    def self.registered(app)
      app.helpers Helpers

      app.enable :esssions

      app.set :username => 'frank',
              :password => 'sinatra'

      app.get '/login' do
        @title = "Login Page"
        slim :login
      end

      app.post '/login' do
        if params[:username] == settings.username && params[:password] == settings.password
          session[:admin] = true
          # flash[:notice] = "You are logged in as #{settings.username}"
          redirect to('/songs')
        else
          # flash[:notice] = "The username or password you entered is incorrect"
          redirect to('/login')
        end
      end

      app.get '/logout' do
        session[:admin] = nil
        # session.clear
        # flash[:notice] = "You have now logged out"
        redirect to('/')
      end
    end
  end
  register Auth
end
