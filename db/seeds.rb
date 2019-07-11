User.create!(user_id: 'test', password: 'password')

4.times do |i|
  Post.create!(
    category_id: i + 1,
    title:       'test',
    body:        'test data',
    top_picture: 'sample.jpg'
  )
end
