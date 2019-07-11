require './test/test_helper.rb'

class PostsControllerTest < MiniTest::Test
  def test_should_be_able_to_post_when_logged_in
    log_in_as_test_user
    post_count = Post.count
    post_a_test_article
    assert_equal post_count + 1, Post.count
    follow_redirect!
    assert_equal "/articles/#{Post.count}", last_request.path_info
  end

  def test_should_redirect_post_when_not_logged_in
    post_count = Post.count
    post_a_test_article
    assert_equal post_count, Post.count
    follow_redirect!
    assert_equal '/login', last_request.path_info
  end

  def test_Should_redirect_if_csrf_token_is_wrong
    log_in_as_test_user
    post '/article_post', params = {
      csrf_token:  'overwrite',
      category_id: 1,
      title:       'Example Title',
      body:        'Lorem ipsum...',
      file:        Rack::Test::UploadedFile.new('test/sample.jpg', 'image/jpeg')
    }
    follow_redirect!
    assert_equal '/login', last_request.path_info
  end
end

# csrf対策のテスト
# ファイルをpostしないといけない
