# bundle exec rake db:migrate:reset
# bundle exec rake db:seed

User.create!(user_id: 'test', password: 'password')

4.times do |i|
  Post.create!(
    category_id: i + 1,
    title:       'test',
    body:        'test data',
    top_picture: 'sample.jpg'
  )
end

categories = ['HTML/CSS', 'JavaScript', 'サイト運営', '他記事']
categories.each_with_index do |n, i|
  Category.create!(
    category_id: i + 1,
    cate_name:   n
  )
end
