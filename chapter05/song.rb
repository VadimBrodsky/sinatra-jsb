require 'dm-core'
require 'dm-migrations'

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/development.db")
end

class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :lyrics, Text
  property :length, Integer
  property :released_on, Date

  def released_on=date
    super Date.strptime(date, '%m/%d/%Y')
  end
end

DataMapper.finalize

# Show all songs
get '/songs' do
  @songs = Song.all
  slim :songs
end

# Create a song form
get '/songs/new' do
  halt(401, 'Not Authorized') unless session[:admin]
  @song = Song.new
  slim :new_song
end

# Show one song
get '/songs/:id' do
  unless Song.get(params[:id]).nil?
    @song = Song.get(params[:id])
    slim :show_song
  else
    redirect to('/songs')
  end
end

# Create a song POST action
post '/songs' do
  song = Song.create(params[:song])
  redirect to("/songs/#{song.id}")
end

# Edit a song form
get '/songs/:id/edit' do
  @song = Song.get(params[:id])
  slim :edit_song
end

# Edit a song PUT action
put '/songs/:id' do
  song = Song.get(params[:id])
  song.update(params[:song])
  redirect to("/songs/#{song.id}")
end

# Delete a song DELETE action
delete '/songs/:id' do
  Song.get(params[:id]).destroy
  redirect to('/songs')
end
