require 'pony'
require 'dotenv'
require_relative 'asset_handler'

Dotenv.load

class Website < ApplicationController

  use AssetHandler

  def send_message
    Pony.mail(
      :from => params[:name] + "<" + params[:email] + ">",
      :to => "charazn37@gmail.com",
      :subject => params[:name] + " has contacted you",
      :body => params[:message],
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

end
