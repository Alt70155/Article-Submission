require './test/test_helper.rb'

class UsersControllerTests < MiniTest::Test
  def test_should_be_logged_out
    log_in_as_test_user
    follow_redirect!
    delete '/logout'
    follow_redirect!
    assert_equal '/login', last_request.path_info
  end
end
