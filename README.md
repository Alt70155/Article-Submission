# Sinatra環境構築メモ

```Bash
bundle init
```

Gemfile

```Ruby
# frozen_string_literal: true

source "http://rubygems.org"

gem 'activerecord'
gem 'bcrypt'
gem 'minitest'
gem 'mysql2'
gem 'rack-flash3'
gem 'rack-test'
gem 'rake'
gem 'redcarpet'
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'sinatra-contrib'
gem 'slim'

```

gemインストール

```Bash
sudo bundle install --path vendor/bundle
```

app.rbを作成

```ruby
get '/' do
  "hello world"
end
```

config.ruを作成

```ruby
require 'rubygems'
require 'bundler'
Bundler.require
require './app.rb'
run Sinatra::Application
```

実行

```Bash
bundle exec rackup config.ru
```

マイグレーション用ファイルを生成するためのRakefileを作成

Rakefile
```Ruby
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
```

database.ymlを作成

```yml
development:
  adapter: mysql2
  database: articles3
  host: localhost
  username: root
  password:
  encoding: utf8
```

DBが無い場合、database.ymlで指定したDBを作成

```Bash
mysql.server start # MySQL起動
mysql -u root # ログイン
```

SQL

```SQL
> CREATE DATABASE articles3;
> USE articles3;
```

マイグレーション用ファイルを作成

```Bash
bundle exec rake db:create_migration NAME=create_categories
bundle exec rake db:create_migration NAME=create_posts
```

日付_create_categories.rbファイルができるので中身を追加

```Ruby
class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories, id: false do |t|
      t.column :category_id, 'INTEGER PRIMARY KEY AUTO_INCREMENT'
      t.string :cate_name, null: false
    end
  end
end
```

日付_create_posts.rbファイルも追加

```Ruby
class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t| # postsがテーブル名
      t.integer :category_id, foreign_key: true # 型をcategory_idと合わせる
      t.string  :title, null: false # stringはVARCHAR(255)
      t.text    :body,  null: false
      t.string  :top_picture, null: false
      t.timestamps # これでcreate_atとupdate_atカラムが定義される
    end
  end
end
```

テーブル作成

```Bash
bundle exec rake db:migrate
```


モデルのファイルを分ける

```Bash
mkdir models
touch models/posts.rb # postsテーブル
```

Rakefileに追記

```Ruby
require './models/posts.rb'
require './models/categories.rb'
```

models/posts.rbとcategories.rbに追記

```Ruby
# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:development)
Time.zone = "Tokyo"
ActiveRecord::Base.default_timezone = :local
```

実行する

```Bash
bundle exec rackup config.ru
# ip指定
bundle exec rackup config.ru -o 0.0.0.0
```

AUTO_INCREMENTの記事を削除した場合

```SQL
ActiveRecord::Base.connection.execute("alter table posts auto_increment = 25;")
```

で修正

## カラムの追加

```terminal
bundle exec rake db:create_migration NAME=categories_add_path
```

```ruby
def change
  add_column :categories, :path, :string
end
```

```terminal
 bundle exec rake db:migrate
```

## yardでドキュメント生成

ドキュメント生成

```terminal
yardoc file_name.rb
```

yardサーバー立ち上げ(port: 8808)

```terminal
yard server
```

irbを使ってrails sのようにモデルを扱う場合、cofigファイルをrequireする必要がある

```terminal
irb
require './app_config.rb'
```