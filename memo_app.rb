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
  @conn ||= PG.connect(dbname: 'memodb', client_encoding: 'UTF8')
end

before do
  conn.exec('CREATE TABLE IF NOT EXISTS memos (id serial, title varchar(255), content text)')
end

def load_memos
  result = conn.exec('SELECT * FROM memos')
  memos = {}
  result.each do |row|
    memos[row['id']] = {
      'id' => row['id'],
      'title' => row['title'],
      'content' => row['content']
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
  @memo = load_memos[@id]
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
  @memo = load_memos[@id]
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
  @id = params[:id]
  @memo = load_memos[@id]
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
  @id = params[:id]
  delete_memo(@id)
  redirect '/memos'
end
