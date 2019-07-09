require './test/test_helper.rb'

class UsersControllerTests < MiniTest::Test
  def test_should_redirect_login_when_not_logged_in
    get '/create_article'
    follow_redirect!
    assert last_response.body.include?('ログイン')
  end

  def test_should_login_create_article_page_when_correct_user
    get '/login'
    assert last_response.body.include?('ログイン')
    post '/login', params = {
      user_id:  'test',
      password: 'password'
    }
    follow_redirect!
    assert last_response.body.include?('Article Post')
  end
end
