require './test/test_config.rb'

class StaticPagesControllerTests < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_response
    get '/login'
    assert_match /ログイン/, last_response.body
  end
end
