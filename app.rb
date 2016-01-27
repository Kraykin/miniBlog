#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'miniblog.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE  TABLE IF NOT EXISTS Posts
		(
			"id" INTEGER PRIMARY KEY  AUTOINCREMENT  UNIQUE,
			created_date DATE,
			content TEXT
		)'
end

get '/' do
	@results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'

	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	@db.execute 'INSERT INTO Posts
		(
			created_date,
			content
		)
		VALUES ( datetime(), ? )', [content]

	redirect to '/'
end