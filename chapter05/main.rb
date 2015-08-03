require 'sinatra'
require 'sinatra/reloader' if settings.development?
require 'sinatra/flash'
require 'slim'
require 'pony'

require './song'

configure do
	set :public_folder, 'assets' # public by default
	set :views, 'templates'      # views by default
	enable :sessions
	set :username, 'frank'
	set :password, 'sinatra'
end

helpers do
	def css(*stylesheets)
		stylesheets.map do |stylsheet|
			"<link href=\"#{stylsheet}.css\" media=\"screen, projection\" rel=\"stylsheet\" />"
		end.join
	end

	def current?(path='/')
		(request.path == path || request.path == path + '/') ? "current" : nil
	end

	def set_title
		@title ||= "Songs By Sinatra"
	end

	def send_message
		Pony.mail(
		:from => params[:name] + "<" + params[:email] + ">",
		:to => 'email@gmail.com',
		:subject => params[:name] + " has contacted you",
		:body => params[:message],
		:via => :smtp,
		:via_options => {
			:address              => 'smtp.gmail.com',
			:port                 => '587',
			:enable_starttls_auto => true,
			:user_name            => 'email@gmail.com',
			:password             => 'super_duper_secret',
			:authentication       => :plain,
			:domain               => 'localhost.localdomain'
		})
	end
end

# before filter - will run before each request
# there are also after filters in sinatra
# can be applied globally or to a specific route
before do
	set_title
end

after '/special' do
	# something that happens only after the special route was invoked
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

post '/contact' do
	send_message
	flash[:notice] = "Thank you for your message. We'll be in touch soon."
	redirect to('/')
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

get '/logout' do
	session.clear
	redirect to('/login')
end
