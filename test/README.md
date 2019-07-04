assert_match 正規表現, 文字列
assert_equal 期待値, 実際の値
assert テスト(真偽値)
assert_nil オブジェクト

last_response.bodyでページのHTMLが取得できる
last_requestで色々使える

```ruby
# パラメータを使ったテスト
def test_with_params
  get '/meet', name: 'Frank'
  assert_equal 'Hello Frank!', last_response.body
end
```

```bash
bundle exec ruby test/static_pages_controller_test.rb
```

http://sinatrab.com/testing.html
