require 'sinatra'
require 'sinatra/reloader' if development?

set :public_folder, 'assets' # public by default
set :views, 'templates'      # views by default

get '/' do
	erb :home
end

get '/about' do
	@title = "All About This Website"
	erb :about
end

get '/contact' do
	erb :contact
	#erb :contact, :layout => :special
end

not_found do
	erb :not_found
end

get '/fake-error' do
	status 500
	"There's nothing wrong, really :p"
end
