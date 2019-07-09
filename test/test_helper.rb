require './app_config.rb'
require 'minitest/autorun'
require 'rack/test'
require "minitest/reporters"
Minitest::Reporters.use!

ENV['RACK_ENV'] = 'test'

class MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end
