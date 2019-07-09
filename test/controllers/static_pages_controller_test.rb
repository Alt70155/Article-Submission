require './test/test_helper.rb'

class StaticPagesControllerTests < MiniTest::Test
  def test_should_get_index
    get '/'
    assert last_response.ok?
    assert_equal '/', last_request.path_info
  end

  def test_should_get_login
    get '/login'
    assert last_response.ok?
    assert_equal '/login', last_request.path_info
  end
end
