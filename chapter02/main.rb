require 'sinatra'
require 'sinatra/reloader' if development?

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

