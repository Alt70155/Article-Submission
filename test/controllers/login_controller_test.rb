require './test/test_helper.rb'

class UsersControllerTests < MiniTest::Test
  def test_should_redirect_login_when_not_logged_in
    get '/create_article'
    follow_redirect!
    assert_equal '/login', last_request.path_info
  end

  def test_should_login_create_article_page_when_correct_user
    get '/login'
    assert_equal '/login', last_request.path_info
    log_in_as_test_user
    follow_redirect!
    assert_equal '/create_article', last_request.path_info
  end

  def test_unregistered_users_can_not_log_in
    post '/login', params = {
      user_id:  'aaaa',
      password: 'bbbb'
    }
    assert_equal '/login', last_request.path_info
  end
end
