require 'sinatra/base'
require './app'

map('/songs') { run SongController }
map('/') { run Website }
