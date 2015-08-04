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

helpers SongHelpers

# Show all songs
get '/songs' do
  # @songs = Song.all
  find_songs
  slim :songs
end

# Create a song form
get '/songs/new' do
  protected!
  @song = Song.new
  slim :new_song
end

# Show one song
get '/songs/:id' do
  unless Song.get(params[:id]).nil?
    @song = find_song
    slim :show_song
  else
    redirect to('/songs')
  end
end

# Edit a song form
get '/songs/:id/edit' do
  @song = find_song
  slim :edit_song
end

# Create a song POST action
post '/songs' do
  flash[:notice] = "Song successfully added" if create_song
  redirect to("/songs/#{@song.id}")
end

# Edit a song PUT action
put '/songs/:id' do
  song = find_song
  if song.update(params[:song])
    flash[:notice] = 'Song successfully updated'
  end
  redirect to("/songs/#{song.id}")
end

# Delete a song DELETE action
delete '/songs/:id' do
  if find_song.destroy
    flash[:notice] = "Song deleted"
  end
  redirect to('/songs')
end
