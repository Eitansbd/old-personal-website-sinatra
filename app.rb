require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'find'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'
require 'pg'
require 'date'

class CustomRender < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
end

require 'pry'

configure do
  enable :sessions
end

ROOT = File.expand_path(File.dirname(__FILE__))

before '/blog*' do 
  @db = if Sinatra::Base.production?
        PG.connect(ENV['DATABASE_URL'])
      else
        PG.connect(dbname: "personal_website")
      end
end

helpers do 
  def post_date(timestamp)
    Date.parse(timestamp).strftime("%^b %-d, %Y")
  end
end

get '/' do 
  erb :home
end

get '/home' do 
  redirect '/'
end

get '/projects' do 
  erb :projects
end

def get_all_posts
  @db.exec("SELECT * FROM posts ORDER BY created_at;")
end

get '/blog' do
  @posts = get_all_posts
  erb :blog
end

def find_file_location
  Find.find("#{ROOT}/public/files/blog") do |path|
    return path if path.end_with?("#{params[:post_name]}.md")
  end
  
  nil
end

def render_markdown(text)
  extras = {
     autolink: true,
     no_intra_emphasis: true,
     disable_indented_code_blocks: true,
     fenced_code_blocks: true,
     strikethrough: true,
     superscript: true,
     lax_spacing: true
   }
  #markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown = Redcarpet::Markdown.new(CustomRender, extras)
  markdown.render(text)
end

def get_post
  @db.exec_params("SELECT * FROM posts WHERE path = $1", [params['post_name']]).first
end

get '/blog/:post_name' do 
  file_location = find_file_location
  redirect '/blog' unless file_location
  
  @post_info = get_post
  content = File.read file_location
  @html_content = render_markdown(content)
  
  erb :blog_post
end

after '/blog*' do 
  @db.close
end