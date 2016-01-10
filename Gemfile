source "https://rubygems.org"

ruby "2.2.4"

gem "sinatra"
gem "sinatra-flash", :git => "https://github.com/SFEley/sinatra-flash.git"
gem "pony", :git => "https://github.com/benprew/pony.git"
gem "slim"
gem "sass"
gem "thin"
gem "datamapper"

group :development do
  gem "dm-sqlite-adapter"
end

group :production do
  gem "pg"
  gem "dm-postgres-adapter"
end
