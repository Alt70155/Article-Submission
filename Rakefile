require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'rake/testtask'
Dir[File.dirname(__FILE__) + '/validators/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each { |f| require f }

# database.ymlを読み込み
#ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# development/testなどを設定
#ActiveRecord::Base.establish_connection(:test)
ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read("database.yml")).result)
# developmentを設定
ActiveRecord::Base.establish_connection(:test)
# タイムゾーン指定
Time.zone = 'Tokyo'
ActiveRecord::Base.default_timezone = :local

# テストを全て実行するrakeタスク
# bundle exec rake testで実行
# 参考　https://www.xmisao.com/2014/06/06/minitest-rakefile.html
task :default => [:test]

Rake::TestTask.new do |test|
  test.test_files = Dir['test/**/*_test.rb']
  test.verbose = true
end
