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
require './env_var.rb'
require './app.rb'

Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/validators/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each { |f| require f }


# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:test)
Time.zone = 'Tokyo'
ActiveRecord::Base.default_timezone = :local
