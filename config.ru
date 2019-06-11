require 'rubygems'
require 'bundler'
require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'redcarpet'
require 'rack-flash'
Bundler.require
require './app.rb'
require './models/posts.rb'
require './models/categories.rb'

run Sinatra::Application
