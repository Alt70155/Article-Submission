require './test/test_helper.rb'

class StaticPagesControllerTests < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_should_get_index
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('Knowledge of Programming')
  end

  def test_should_get_login
    get '/login'
    p last_response.body
    assert last_response.ok?
    assert last_response.body.include?('ログイン')
  end
end
