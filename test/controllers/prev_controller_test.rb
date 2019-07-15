require './test/test_helper.rb'

class PrevControllerTest < MiniTest::Test
  def test_xxx
    log_in_as_test_user
    post 'article_prev', params = {
      category_id: 1,
      title:       'test-title',
      body:        '![]()',
      file:        Rack::Test::UploadedFile.new('test/sample.jpg', 'image/jpeg'),
      article_img_files: Rack::Test::UploadedFile.new('test/sample.jpg', 'image/jpeg')
    }

    post 'article_post', params = {
      category_id: 1,
      title:       'test-title',
      body:        '![]()',
      back:        'back'
    }
    assert !File.exist?('public/img/sample.jpg')
  end
end
