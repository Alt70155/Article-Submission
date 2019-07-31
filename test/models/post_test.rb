require './test/test_helper.rb'

class PostTest < MiniTest::Test
  def setup
    @post = Post.new(
      category_id: 1,
      title:       'Example Title',
      body:        'Lorem ipsum...',
      top_picture: 'example_picture.jpg'
    )
  end

  def test_should_be_valid
    assert @post.valid?
  end

  def test_category_should_be_present
    @post.category_id = ''
    assert_equal false, @post.valid?
  end

  def test_category_should_be_integer
    @post.category_id = 'a'
    assert_equal false, @post.valid?
  end

  def test_title_should_be_present
    @post.title = ''
    assert_equal false, @post.valid?
  end

  def test_title_should_not_be_too_long
    @post.title = 'a' * 76
    assert_equal false, @post.valid?
  end

  def test_body_should_be_present
    @post.body = ''
    assert_equal false, @post.valid?
  end

  def test_body_should_not_be_too_long
    @post.body = 'a' * 20001
    assert_equal false, @post.valid?
  end

  def test_top_picture_should_be_a_fixed_extension
    @post.top_picture = 'aaaaa'
    assert_equal false, @post.valid?
    @post.top_picture = 'aaa.jpg.mov'
    assert_equal false, @post.valid?
  end
end
