enable :sessions
# put/deleteフォームをサポートしないブラウザで_methodのおまじないを使えるようにする
enable :method_override
# use Rack::Flash # flashはセッションを使うためenable :sessionsの下に書く
use Rack::Session::Cookie
# クッキー内のセッションデータはセッション秘密鍵(session secret)で署名されます。
# Sinatraによりランダムな秘密鍵が個別に生成されるらしい
# 個別で設定する場合は↓
# set :session_secret, 'super secret'

get '/' do
  @post = Post.order('id DESC')
  @page_name = 'index'
  slim :index
end

# ---- カテゴリー ----

get '/category/:cate_name' do
  @page_name = 'index'
  # URLに指定されたカテゴリー名を数字に置き換える
  category_name_to_id = { 'html-css': 1, 'js': 2, 'site': 3, 'etc': 4 }
  cate_id = category_name_to_id[params[:cate_name].to_sym]
  if cate_id
    @cate_name = Category.find(cate_id).cate_name
    @post_by_category = Post.where(category_id: cate_id).order('id DESC')
    slim :category
  else
    slim :not_found
  end
end

# ---- 記事投稿関連 ----

get '/articles/:id' do
  @page_name = 'article'
  @post = Post.find_by(id: params[:id])
  if @post
    # その他記事を降順で6個取得
    @other_articles = Post.order('id DESC').first(6)
    slim :articles
  else
    slim :not_found
  end
end

get '/create_article' do
  login_required
  csrf_token_generate
  @category = Category.all
  slim :create_article, layout: nil
end

post '/article_post' do
  login_required
  @page_name = 'article'
  # csrf対策
  redirect '/create_article' unless params[:csrf_token] == session[:csrf_token]

  # params[:file]がnilの場合、params[:file][:filename]で例外が発生する
  # prevから投稿する場合、画像は保存してあるのでparams[:pic_name]にファイル名を格納してそれを使う
  file = params[:file]
  top_pic_name = params[:pic_name] || (file && file[:filename])
  @post = Post.new(
    category_id: params[:category_id],
    title:       params[:title],
    body:        params[:body],
    top_picture: top_pic_name
  )

  if params[:back].nil? && img_valid?(@post.body, params[:article_img_files]) && @post.save
    # top画像ファイル保存
    File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(file[:tempfile].read) } if file
    # 記事内画像があればそれも保存
    params[:article_img_files]&.each do |img|
      File.open("public/img/#{img[:filename]}", 'wb') { |f| f.write(img[:tempfile].read) }
    end
    # flash[:notice] = '投稿完了'
    redirect "/articles/#{@post.id}"
  else
    # プレビュー画面から修正に戻った場合
    if params[:back]
      File.delete("public/img/#{@post.top_picture}") if File.exist?("public/img/#{@post.top_picture}")
      # 記事内画像名をセッションで受け取って削除
      session[:img_files]&.each do |img_name|
        File.delete("public/img/#{img_name}") if File.exist?("public/img/#{img_name}")
      end
      # プレビューから戻った場合、create_articleをリダイレクトではなくレンダリングするため、csrf_tokenが作られない。
      # そのためもう一度作成する
      csrf_token_generate
    end

    @category = Category.all
    # エラーメッセージor履歴を表示させたいのでレンダー
    slim :create_article, layout: nil
  end
end

post '/article_prev' do
  login_required
  redirect '/create_article' unless params[:csrf_token] == session[:csrf_token]
  csrf_token_generate
  @page_name = 'article'
  file = params[:file]
  top_pic_name = file ? file[:filename] : nil
  @post = Post.new(
    id:          Post.count + 1, # ダミー
    category_id: params[:category_id],
    title:       params[:title],
    body:        params[:body],
    top_picture: top_pic_name
  )

  img_files = params[:article_img_files]
  # プレビューでは記事をDBに保存しないのでvalid?でチェックし、画像は保存する
  if img_valid?(@post.body, img_files) && @post.valid?
    File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(file[:tempfile].read) }
    if img_files
      # 修正に戻る場合、記事内画像を削除するためにセッションでファイル名を保持する
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
end

# ---- ログイン機能 ----

get '/login' do
  slim :login, layout: nil
end

post '/login' do
  user = User.find_by(user_id: params[:user_id])

  # ユーザーが存在すればパスワードを比較する
  if user&.authenticate(params[:password])
    session[:user_id] = user.user_id
    redirect '/create_article'
  else
    slim :login, layout: nil
  end
end

delete '/logout' do
  login_required
  session.clear
  redirect 'login'
end

# ---- その他ルーティング ----

not_found do
  slim :not_found
end

get '/profile' do
  slim :profile, layout: nil
end

get '/portfolio' do
  @page_name = 'portfolio'
  @title     = 'My Portfolio'
  slim :portfolio
end
