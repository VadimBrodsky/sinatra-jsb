require 'sinatra/base'
require './sinatra/auth'   # custom authorization extension
# require 'sinatra/reloader' if settings.development?
require 'sinatra/flash'
require 'slim'
require 'sass'
require 'pony'
require 'coffee-script'

class ApplicationController < Sinatra::Base
	register Sinatra::Auth
	register Sinatra::Flash

  configure do
    set :start_time, Time.now
  end

	before do
		set_title
    last_modified settings.start_time
    etag settings.start_time.to_s
    cache_control :public, :must_revalidate
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
end
