# bundle exec rake db:migrate:reset
# bundle exec rake db:seed

User.create!(user_id: 'test', password: 'password', password_confirmation: 'password')

1.times do |i|
  Post.create!(
    category_id: 1,
    title:       'テストタイトル',
    body:        'test data',
    top_picture: 'page2.jpg'
  )
end

categories = %w(HTML/CSS JavaScript サイト運営 他記事)
categories.each_with_index do |n, i|
  Category.create!(
    category_id: i + 1,
    cate_name:   n
  )
end
