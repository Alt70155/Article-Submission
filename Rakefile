require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
# require 'bcrypt'
# Dir[File.dirname(__FILE__) + '/models/*.rb'].each { |f| require f }

# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:development)
# タイムゾーン指定
Time.zone = 'Tokyo'
ActiveRecord::Base.default_timezone = :local
