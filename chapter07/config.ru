require 'sinatra/base'
require_relative 'app'
require_relative 'website-controller'
require_relative 'song-controller'

map('/songs') { run SongController }
map('/') { run WebsiteController }
