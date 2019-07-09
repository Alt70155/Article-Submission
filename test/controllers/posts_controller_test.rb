require './test/test_helper.rb'

class PostsControllerTest < MiniTest::Test
  def test_should_redirect_post_when_not_logged_in
    post_count = Post.count
    post_a_test_article
    assert_equal post_count, Post.count
    follow_redirect!
    assert_equal '/login', last_request.path_info
  end
end
