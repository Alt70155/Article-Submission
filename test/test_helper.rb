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

  def log_in_as_test_user
    post '/login', params = {
      user_id:  'test',
      password: 'password'
    }
  end

  def post_a_test_article(cate: 1, title: 'Example', body: 'Lorem...', ex: nil)
    params = {
      category_id: cate,
      title:       title,
      body:        body,
      file:        Rack::Test::UploadedFile.new('test/sample.jpg', 'image/jpeg')
    }
    params.merge!(ex) if ex

    post '/article_post', params
  end

  Minitest.after_run do
    # 全てのテストが終わったあと、dbをリセットする
    system('DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate:reset')
    system('DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:seed')
  end
end
