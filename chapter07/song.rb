require 'dm-core'
require 'dm-migrations'
require './app'

class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :lyrics, Text
  property :length, Integer
  property :released_on, Date
  property :likes, Integer, :default => 0

  def released_on=date
    super Date.strptime(date, '%m/%d/%Y')
  end
end

DataMapper.finalize

module SongHelpers
  def find_songs
    @songs = Song.all
  end

  def find_song
    Song.get(params[:id])
  end

  def create_song
    @song = Song.create(params[:song])
  end
end

class SongController < ApplicationController
  enable :method_override

  helpers SongHelpers

  configure do
		set :public_folder, 'assets' # public by default
		set :views, 'templates'      # views by default
		enable :sessions
		set :username, 'admin'
		set :password, 'password'
  end

  configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/development.db")
  end

  configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
  end

  # Show all songs
  get '/' do
    find_songs
    slim :songs
  end

  # Create a song form
  get '/new' do
    protected!
    @song = Song.new
    slim :new_song
  end

  # Show one song
  get '/:id' do
    unless Song.get(params[:id]).nil?
      @song = find_song
      slim :show_song
    else
      redirect to('/')
    end
  end

  # Edit a song form
  get '/:id/edit' do
    protected!
    @song = find_song
    slim :edit_song
  end

  # Create a song POST action
  post '/' do
    protected!
    flash[:notice] = "Song successfully added" if create_song
    redirect to("/#{@song.id}")
  end

  # Edit a song PUT action
  put '/:id' do
    song = find_song
    if song.update(params[:song])
      flash[:notice] = 'Song successfully updated'
    end
    redirect to("/#{song.id}")
  end

  # Delete a song DELETE action
  delete '/:id' do
    if find_song.destroy
      flash[:notice] = "Song deleted"
    end
    redirect to('/')
  end

  post '/:id/like' do
    @song = find_song
    @song.likes = @song.likes.next
    @song.save
    redirect to "/#{@song.id}" unless request.xhr?
    slim :like, :layout => false
  end
end
