require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# development/testなどを設定
ActiveRecord::Base.establish_connection(:test)
# タイムゾーン指定
Time.zone = 'Tokyo'
ActiveRecord::Base.default_timezone = :local

# テストを全て実行するrakeタスク
# bundle exec rake testで実行
task :default => [:test]

Rake::TestTask.new do |test|
  test.test_files = Dir['test/**/*_test.rb']
  test.verbose = true
end
