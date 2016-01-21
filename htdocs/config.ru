require 'rubygems'
require 'sinatra'
require 'rack'
require 'rack/contrib'

use Rack::PostBodyContentTypeParser

Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file }
set :views, File.expand_path('../views', __FILE__)

map('/example') { run HelloController }
map('/register-token') { run RegisterTokenController }
#map('/') { run ApplicationController }
