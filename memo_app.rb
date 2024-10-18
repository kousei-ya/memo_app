# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def conn
  @conn ||= PG.connect(dbname: 'memodb')
end

configure do
  result = conn.exec("SELECT * FROM information_schema.tables WHERE table_name = 'memos'")
  conn.exec('CREATE TABLE memos (id serial, title varchar(255), content text)') if result.values.empty?
end

def load_memos
  result = conn.exec('SELECT * FROM memos')
  memos = {}
  result.each do |row|
    memos[row['id']] = {
      'id' => row['id'].force_encoding('UTF-8'),
      'title' => row['title'].force_encoding('UTF-8'),
      'content' => row['content'].force_encoding('UTF-8')
    }
  end
  memos
end

def create_memo(title, content)
  conn.exec_params('INSERT INTO memos(title, content) VALUES ($1, $2);', [title, content])
end

def edit_memo(title, content, id)
  conn.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [title, content, id])
end

def delete_memo(id)
  conn.exec_params('DELETE FROM memos WHERE id = $1', [id])
end

not_found do
  'This is nowhere to be found.'
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @id = params[:id]
  memos = load_memos
  @memo = memos[@id]
  if @memo
    erb :show
  else
    status 404
    erb :error_not_found
  end
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  create_memo(title, content)
  redirect '/memos'
end

get '/memos/:id/edit' do
  @id = params[:id]
  memos = load_memos
  @memo = memos[@id]
  if @memo
    @title = @memo['title']
    @content = @memo['content']
    erb :edit
  else
    status 404
    erb :error_not_found
  end
end

patch '/memos/:id' do
  memos = load_memos
  @id = params[:id]
  @memo = memos[@id]
  if @memo
    title = params[:title]
    content = params[:content]
    edit_memo(title, content, @id)
    redirect '/memos'
  else
    status 404
    erb :error_not_found
  end
end

delete '/memos/:id' do
  memos = load_memos
  @id = params[:id]
  delete_memo(@id)
  redirect '/memos'
end
