require 'rubygems'
require 'sinatra'
require 'find'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class CustomRender < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
end

require 'pry'

configure do
  enable :sessions
end

ROOT = File.expand_path(File.dirname(__FILE__))

get '/' do 
  erb :home
end

get '/home' do 
  redirect '/'
end

get '/projects' do 
  erb :projects
end

get '/blog' do 
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
  markdown = Redcarpet::Markdown.new(CustomRender, extras)
  markdown.render(text)
end

get '/blog/:post_name' do 
  file_location = find_file_location
  redirect '/blog' unless file_location
  
  content = File.read file_location
  @html_content = render_markdown(content)
  
  erb :blog_post
end