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
  File.write('memo.json', JSON.pretty_generate(memos))
end

not_found do
  erb :error
end

get '/' do
  redirect '/memo'
end

get '/memo' do
  @memos = load_memos
  erb :index
end

get '/memo/:id/show' do
  @id = params[:id]
  @memo = load_memos[@id]
  if @memo
    erb :show
  else
    halt 404, 'メモが見つかりません'
  end
end

get '/memo/new' do
  erb :new
end

post '/memo' do
  memos = load_memos
  id = SecureRandom.uuid
  memos[id] = { 'title' => params[:title], 'content' => params[:content] }
  save_memos(memos)
  redirect '/memo'
end

get '/memo/:id/edit' do
  @id = params[:id]
  @memo = load_memos[@id]
  erb :edit
end

patch '/memo/:id' do
  memos = load_memos
  id = params[:id]
  memos[id]['title'] = params[:title]
  memos[id]['content'] = params[:content]
  save_memos(memos)
  redirect '/memo'
end

delete '/memo/:id/show' do
  memos = load_memos
  memos.delete(params[:id])
  save_memos(memos)
  redirect '/memo'
end
