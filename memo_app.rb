# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def load_memos
  File.exist?('memo.json') ? JSON.parse(File.read('memo.json')) : {}
end

def save_memos(memos)
  File.write('memo.json', JSON.generate(memos))
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
    erb :error_404
  end
end

post '/memos' do
  memos = load_memos
  id = SecureRandom.uuid
  memos[id] = { 'title' => params[:title], 'content' => params[:content] }
  save_memos(memos)
  redirect '/memos'
end

get '/memos/:id/edit' do
  @id = params[:id]
  @memo = load_memos[@id]
  if @memo
    erb :edit
  else
    status 404
    erb :error_404
  end
end

patch '/memos/:id' do
  memos = load_memos
  id = params[:id]
  @memo = memos[id]
  if @memo
    memos[id]['title'] = params[:title]
    memos[id]['content'] = params[:content]
    save_memos(memos)
    redirect '/memos'
  else
    status 404
    erb :error_404
  end
end

delete '/memos/:id' do
  memos = load_memos
  memos.delete(params[:id])
  save_memos(memos)
  redirect '/memos'
end
