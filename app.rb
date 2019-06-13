require 'rubygems'
require 'bundler'
require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'redcarpet'
require './models/posts.rb'
require './models/categories.rb'
require 'rack-flash'

require './helpers/img_valid?.rb'
require './helpers/markdown.rb'

enable :sessions
use Rack::Flash # flashはセッションを使うためenable :sessionsの下に書く
# use Rack::Session::Cookie
# クッキー内のセッションデータはセッション秘密鍵(session secret)で署名されます。
# Sinatraによりランダムな秘密鍵が個別に生成されるらしい
# 個別で設定する場合は↓
# set :session_secret, 'super secret'

get '/' do
  @post = Post.order('id DESC')
  slim :index
end

get '/create_article' do
  @category = Category.all
  slim :create_article, layout: nil
end

get '/category/:cate_name' do
  # URLに指定されたカテゴリーを変換
  @cate_name = case params[:cate_name]
               when 'html-css'   then 'HTML/CSS'
               when 'javascript' then 'JavaScript'
               when 'site'       then 'サイト運営'
               when 'etc'        then '他記事'
               end
  if @cate_name.nil?
    slim :not_found
  else
    selected_cate_id = Category.find_by(cate_name: @cate_name).category_id
    @post_by_category = Post.where(category_id: selected_cate_id)
    slim :category
  end
end

get '/articles/:id' do
  if params[:id].to_i > Post.count
    slim :not_found
  else
    @post = Post.find(params[:id])
    # その他記事を降順で6個取得
    @other_articles = Post.order('id DESC').first(6)
    @category = Category.where(category_id: @post.category_id)
    slim :articles
  end
end

post '/article_post' do
  # 画像ファイル自体はモデルを持っていないため、存在チェックをコントローラで行う
  # params[:file]がnilの場合、params[:file][:filename]で例外が発生する
  # prevから投稿する場合、画像は保存してあるのでparams[:pic_name]にファイル名を格納してそれを使う
  if params[:file] || params[:pic_name]
    pic_name = params[:pic_name] || params[:file][:filename]
    @post = Post.new(
      category_id: params[:category_id],
      title: params[:title],
      body: params[:body],
      top_picture: pic_name
    )

    img_files = params[:article_img_files]
    if params[:back].nil? && img_valid?(@post.body, img_files) && @post.save
      # top画像ファイル保存
      if params[:file]
        File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(params[:file][:tempfile].read) }
      end
      # 記事内画像があればそれも保存
      img_files&.each do |img|
        File.open("public/img/#{img[:filename]}", 'wb') { |f| f.write(img[:tempfile].read) }
      end
      flash[:notice] = '投稿完了'
      redirect "/articles/#{@post.id}"
    else
      # プレビュー画面から修正に戻った場合
      if params[:back]
        File.delete("public/img/#{@post.top_picture}") if File.exist?("public/img/#{@post.top_picture}")
        # 記事内画像名をセッションで受け取って削除
        session[:img_files]&.each do |img_name|
          File.delete("public/img/#{img_name}") if File.exist?("public/img/#{img_name}")
        end
      end
      @category = Category.all
      # エラーメッセージを表示させたいのでレンダーする
      slim :create_article
    end
  else
    redirect '/'
  end
end

post '/article_prev' do
  if params[:file]
    @post = Post.new(
      id:      Post.count + 1, # ダミー
      category_id: params[:category_id],
      title:   params[:title],
      body:    params[:body],
      top_picture: params[:file][:filename]
    )

    img_files = params[:article_img_files]
    # プレビューなので保存しないでvalid?だけチェックし、画像は保存する
    # 画像タグがない かつ 画像がなければ画像の検査はしない　それ以外の場合は全て画像を検査する
    if img_valid?(@post.body, img_files) && @post.valid?
      File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(params[:file][:tempfile].read) }
      if img_files
        # 修正に戻った場合、記事内画像ファイルの名前をセッションで保持し、削除する
        session[:img_files] = []
        img_files.each do |img|
          File.open("public/img/#{img[:filename]}", 'wb') { |f| f.write(img[:tempfile].read) }
          session[:img_files] << img[:filename]
        end
      end
      @category = Category.where(category_id: @post.category_id)
      slim :article_prev
    else
      # エラーメッセージを表示させたいのでレンダリング
      @category = Category.all
      slim :create_article, layout: nil
    end
  else
    redirect '/'
  end
end

get '/profile' do
  slim :profile, layout: nil
end

get '/portfolio' do
  @page_name = 'portfolio'
  @title     = 'My Portfolio'
  slim :portfolio
end
