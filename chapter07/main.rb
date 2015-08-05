require 'sinatra/base'
require './sinatra/auth'   # custom authorization extension
# require 'sinatra/reloader' if settings.development?
require 'sinatra/flash'
require 'slim'
require 'sass'
require 'pony'
require 'coffee-script'

class Website < Sinatra::Base
	register Sinatra::Auth
	register Sinatra::Flash

	configure do
		set :public_folder, 'assets' # public by default
		set :views, 'templates'      # views by default
		enable :sessions
		set :username, 'admin'
		set :password, 'password'
	end

	configure :development do
		set :email_address => 'smtp.gmail.com',
				:email_user_name => 'Username',
				:email_password => 'secret',
				:email_domain => 'locahost.localdomain'
	end

	configure :production do
		set :email_address => 'smtp.sendgrid.net',
      :email_user_name => ENV['SENDGRID_USERNAME'],
      :email_password => ENV['SENDGRID_PASSWORD'],
      :email_domain => 'heroku.com'
	end

	before do
		set_title
	end

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

	get ('/styles.css'){ scss :styles }
	get ('/javascripts/application.js') { coffee :application }

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
end
