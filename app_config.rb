require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'redcarpet'
require 'bcrypt'
require 'rack-flash'
require './app.rb'
# helperを全て読み込み
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each { |f| require f }

# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:development)
Time.zone = 'Tokyo'
ActiveRecord::Base.default_timezone = :local
