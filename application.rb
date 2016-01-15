require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/reloader'
require './sinatra/auth'
require 'slim'
require 'sass'
require 'coffee-script'
require 'v8'


class ApplicationController < Sinatra::Base
  register Sinatra::Flash #Must register when using Sinatra::Base as per Github https://github.com/SFEley/sinatra-flash
  register Sinatra::Auth

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
end
