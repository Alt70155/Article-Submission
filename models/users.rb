# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:development)
Time.zone = "Tokyo"
ActiveRecord::Base.default_timezone = :local

class User < ActiveRecord::Base
  has_secure_password
end
# User.new(user_id: 'aaa', password: 'password', password_confirmation: 'password')
