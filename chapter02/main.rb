require 'sinatra'
require 'sinatra/reloader' if development?

set :public_folder, 'assets' # public by default
set :views, 'templates'      # views by default

get '/' do
	erb :home
end

get '/about' do
	erb :about
end

get '/contact' do
	erb :contact
	#erb :contact, :layout => :special
end

