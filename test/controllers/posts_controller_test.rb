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
    post_a_test_article(ex: { csrf_token: 'overwrite' })
    follow_redirect!
    assert_equal '/login', last_request.path_info
  end

  def test_should_select_an_image_in_the_article_if_there_is_an_in_article_image_tag
    log_in_as_test_user
    post_count = Post.count
    post_a_test_article(body: '![]()', ex: { 'article_img_files[]': Rack::Test::UploadedFile.new('test/sample.jpg', 'image/jpeg') })
    assert_equal post_count + 1, Post.count
  end

  def test_should_not_post_if_you_have_an_image_tag_but_no_image
    log_in_as_test_user
    post_count = Post.count
    post_a_test_article(body: '![]()')
    assert_equal post_count, Post.count
  end

  def test_should_not_post_if_no_image_tag_but_there_is_an_image
    log_in_as_test_user
    post_count = Post.count
    post_a_test_article(ex: { 'article_img_files[]': Rack::Test::UploadedFile.new('test/sample.jpg', 'image/jpeg') })
    assert_equal post_count, Post.count
  end

  # 記事投稿に失敗し、その後記事プレビューに失敗するとログイン画面にリダイレクトされるバグを再現したテスト
  def test_if_you_fail_to_post_an_article_and_then_fail_to_preview_an_article_you_will_not_be_redirected_to_the_login_screen
    log_in_as_test_user
    post '/article_post'
    assert last_response.body.include?('Article Post')
    post '/article_prev'
    assert last_response.body.include?('Article Post')
  end

  def test_xxx
    log_in_as_test_user
    post '/article_prev'
    assert last_response.body.include?('Article Post')
    post '/article_post'
    assert last_response.body.include?('Article Post')
  end
end
