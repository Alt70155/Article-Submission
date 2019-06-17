class User < ActiveRecord::Base
  has_secure_password
  # has_secure_passwordを使う場合はbcryptをgemに追加する
  # これを追加するとpasswordとconfirmというDBのカラムに対応しない属性が追加される
  # user = User.new(user_id: 'test', password: 'password', password_confirmation: 'password')
  # user.password_digest #=> $2a$12$JKHTYNafvWuyC.pBq8...
end
