require './test/test_helper.rb'

class UsersControllerTests < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_should_redirect_login_when_not_logged_in
    # get '/create_article'
    # assert last_response.body
  end

  def test_should_login_create_article_page_when_correct_user
    get '/login'
    assert last_response.body.include?('ログイン')
    post '/login', params = {
      user_id:  'test',
      password: 'password'
    }
    p last_response.body #=> 空文字""が返る
    assert last_response.body.include?('Article Post') #=> false
  end
end
