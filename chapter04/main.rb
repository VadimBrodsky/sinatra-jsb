require 'sinatra'
require 'sinatra/reloader' if settings.development?
require 'slim'

require './song'

set :public_folder, 'assets' # public by default
set :views, 'templates'      # views by default

get ('/styles.css'){ scss :styles }

get '/' do
	slim :home
end

get '/about' do
	@title = "All About This Website"
	slim :about
end

get '/contact' do
	slim :contact
	#slim :contact, :layout => :special
end

not_found do
	slim :not_found
end

get '/fake-error' do
	status 500
	"There's nothing wrong, really :p"
end

get '/environment' do
	if settings.development?
		"development"
	elsif settings.production?
		"production"
	elsif settings.test?
		"test"
	else
		"Something else?"
	end
end
