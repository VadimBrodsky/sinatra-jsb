require 'sinatra'
require 'sinatra/reloader' if settings.development?
require 'slim'

require './song'

configure do
	set :public_folder, 'assets' # public by default
	set :views, 'templates'      # views by default
	enable :sessions
	set :username, 'frank'
	set :password, 'sinatra'
end

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

get '/set/:name' do
	session[:name] = params[:name]
end

get '/get/hello' do
	"Hello #{session[:name]}"
end

get '/login' do
	slim :login
end

post '/login' do
	if params[:username] == settings.username && params[:password] == settings.password
		session[:admin] = true
		redirect to('/songs')
	else
		slim :login
	end
end
