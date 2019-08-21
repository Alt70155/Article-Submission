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
require 'will_paginate'
require 'will_paginate/active_record'
require './app.rb'

Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/validators/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each { |f| require f }

#env = ARGV[0] == 'config.ru' ? :production : ARGV[0]&.to_sym
# irb起動用にenvがnilならproductionに設定
#env = :test if env.nil?
# database.ymlを読み込み
# ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# database.ymlにERBを書くためERB.newをかませる
ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read("database.yml")).result)
# developmentを設定
ActiveRecord::Base.establish_connection(:production)
Time.zone = 'Tokyo'
ActiveRecord::Base.default_timezone = :local
