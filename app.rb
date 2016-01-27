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
			username TEXT,
			post TEXT
		)'
	@db.execute 'CREATE  TABLE IF NOT EXISTS Comments
		(
			"id" INTEGER PRIMARY KEY  AUTOINCREMENT  UNIQUE,
			post_id INTEGER,
			created_date DATE,
			username TEXT,
			comment TEXT
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
	@post = params[:post]
	@username = params[:username]

	hh = { :username => "Type your username", 
		   :post => "Type post text" }

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ''
		return erb :new
	end

	@db.execute 'INSERT INTO Posts
		(
			created_date,
			username,
			post
		)
		VALUES ( datetime(), ?, ? )', [@username, @post]

	redirect to '/'
end

get '/post/:post_id' do
	post_id = params[:post_id]
	
	result = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
	@row = result[0]

	@comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id]
	
	erb :post
end

post '/post/:post_id' do
	post_id = params[:post_id]
	comment = params[:comment]
	username = params[:username]
	
	if comment.length <= 0
		@error = 'Type comment text'
		redirect to('/post/' + post_id)
	end

	@db.execute 'INSERT INTO Comments
		(
			post_id,
			created_date,
			username,
			comment
		)
		VALUES ( ?, datetime(), ?, ? )', [post_id, username, comment]

	redirect to('/post/' + post_id)

end