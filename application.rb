require 'sinatra/base'
require 'slim'
require 'sass'
require 'sinatra/flash'
require 'sinatra/reloader'
require './sinatra/auth'


class ApplicationController < Sinatra::Base
  register Sinatra::Flash
  register Sinatra::Auth
end
