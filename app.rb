enable :sessions
# put/deleteフォームをサポートしないブラウザで_methodのおまじないを使えるようにする
enable :method_override
# use Rack::Flash # flashはセッションを使うためenable :sessionsの下に書く
# use Rack::Session::Cookie
# クッキー内のセッションデータはセッション秘密鍵(session secret)で署名されます。
# Sinatraによりランダムな秘密鍵が個別に生成されるらしい
# 個別で設定する場合は↓
# set :session_secret, 'super secret'

get '/' do
  post_ct   = Post.count
  split_num = 12
  pager_num = post_ct / split_num
  # 12区切りで分割した後の残りページがあるかどうかを計算して、あれば1ページャー追加する
  pager_num += 1 unless ((post_ct - pager_num * split_num) % split_num).zero?

  # パラメータがnil(パラメータ無し)か、数字の場合のみ
  if params[:page].nil? || /\A[1-9][0-9]*\z/ =~ params[:page] && params[:page].to_i <= pager_num
    @post = Post.order('id DESC')
    @page_name = 'index'
    @title = 'Blog'
    @pager = Post.paginate(page: params[:page], per_page: split_num).order('id DESC')
    slim :index
  else
    slim :not_found
  end
end

# 過去のURL(page1やpage1.html)を今のURLに置き換えてリダイレクトする処理
['/articles/page*.html', '/articles/page*'].each do |route|
  get route do
    # アスタリスク(ワイルドカード)で指定したパラメータはparams['splat']で取得
    # 取得したパラメータからdeleteで数字のみにしてページ番号を取得
    page_num = params['splat'][0].delete('^0-9').to_i
    redirect "/articles/#{page_num}"
  end
end

# ---- カテゴリー ----

get '/category/:cate_name' do
  @page_name = 'index'
  # URLに指定されたカテゴリー名を数字に置き換える
  category_name_to_id = { 'html-css' => 1, 'js' => 2, 'site' => 3, 'etc' => 4 }
  cate_id = category_name_to_id[params[:cate_name]]

  if cate_id
    @cate_name = Category.find(cate_id).cate_name
    @title = @cate_name
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
    @is_login = !current_user.nil?
    # その他記事を降順で6個取得
    @title          = @post.title
    @other_articles = Post.order('id DESC').first(6)
    @description    = @post.body[0..100].gsub(/##/, '').gsub(/(\r\n?|\n)/, ' ')

    if @is_login
      session[:page_number] = @post.id
      @edit_path = env_var('edit_path')
    end

    slim :articles
  else
    slim :not_found
  end
end

# create_article
get @create_article_path do
  login_required
  csrf_token_generate

  @category = Category.all
  slim :create_article, layout: nil
end

post '/article_post' do
  login_required

  @page_name = 'article'

  redirect env_var('create_article_path') unless params[:csrf_token] == session[:csrf_token]

  # params[:file]がnilの場合、params[:file][:filename]で例外が発生する
  # prevから投稿する場合、画像は保存してあるのでparams[:pic_name]にファイル名を格納してそれを使う
  thumbnail_file = params[:file]
  thumbnail_name = params[:pic_name] || (thumbnail_file && thumbnail_file[:filename].downcase)

  # img_files_in_articleに格納するのは画像名の入った配列かnilにして、ファイルの保存はparamsを直接用いる
  image_name_in_article = params[:article_img_files]&.map { |img| img[:filename].downcase }
  image_name_in_article = session[:img_files_name_in_article] if image_name_in_article.nil?

  @post = Post.new(
    category_id:          params[:category_id],
    title:                params[:title],
    body:                 params[:body],
    top_picture:          thumbnail_name,
    img_files_in_article: image_name_in_article
  )

  if params[:back].nil? && @post.save
    # top画像ファイル保存
    File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(thumbnail_file[:tempfile].read) } if thumbnail_file
    # 記事内画像があればそれも保存
    params[:article_img_files]&.each do |img|
      File.open("public/img/#{img[:filename]}", 'wb') { |f| f.write(img[:tempfile].read) }
    end

    session[:img_files_name_in_article] = nil

    redirect "/articles/#{@post.id}"
  else
    # プレビュー画面から修正に戻った場合
    if params[:back]
      File.delete("public/img/#{@post.top_picture}") if File.exist?("public/img/#{@post.top_picture}")
      # 記事内画像名をセッションで受け取って削除
      session[:img_files_name_in_article]&.each do |img_name|
        File.delete("public/img/#{img_name}") if File.exist?("public/img/#{img_name}")
      end
    end

    session[:img_files_name_in_article] = nil
    # 投稿に失敗した場合、create_articleをリダイレクトではなくレンダリングするため、csrf_tokenが作られないのでもう一度作成する
    csrf_token_generate

    @category = Category.all
    slim :create_article, layout: nil
  end
end

post '/article_prev' do
  login_required

  @page_name = 'article'

  redirect env_var('create_article_path') unless params[:csrf_token] == session[:csrf_token]

  # 修正・投稿の両方にトークンが必要な為、最初に記述
  csrf_token_generate

  thumbnail_file = params[:file]
  thumbnail_name = thumbnail_file ? thumbnail_file[:filename].downcase : nil

  # 記事内画像があれば画像名を、なければnilを格納する
  image_name_in_article = params[:article_img_files]&.map { |img| img[:filename].downcase }

  @post = Post.new(
    id:                   Post.count + 1, # ダミー
    category_id:          params[:category_id],
    title:                params[:title],
    body:                 params[:body],
    top_picture:          thumbnail_name,
    img_files_in_article: image_name_in_article
  )

  # プレビューでは記事をDBに保存しないのでvalid?でチェックし、画像は保存する
  if @post.valid?
    File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(thumbnail_file[:tempfile].read) }

    if @post.img_files_in_article
      # 修正に戻る場合、記事内画像を削除するためにセッションでファイル名を保持する
      session[:img_files_name_in_article] = params[:article_img_files].map do |img|
        File.open("public/img/#{img[:filename]}", 'wb') { |f| f.write(img[:tempfile].read) }
        img[:filename]
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

# ---- 編集機能 ----

get @edit_path do
  login_required
  csrf_token_generate
  @post = Post.find(session[:page_number])
  @category = Category.all

  slim :edit, layout: nil
end

post '/article_update' do
  login_required
  redirect '/' unless params[:csrf_token] == session[:csrf_token]

  @post = Post.find(params[:id])
  # @post.update!(title: params[:title], body: params[:body], category_id: params[:category_id])
  # 今回はvalidationを回避したい為、update_columnsを使う
  # update_columnsはupdated_atを更新しないので自力で更新
  unless params[:thumbnail].nil?
    File.open("public/img/#{params[:thumbnail][:filename]}", 'wb') { |f| f.write(params[:thumbnail][:tempfile].read) }
    unless @post.update(top_picture: params[:thumbnail][:filename])
      redirect env_var('edit_path')
    end
  end
  @post.update_columns(title: params[:title],
                       body: params[:body],
                       category_id: params[:category_id],
                       updated_at: Time.now)

  redirect "articles/#{@post.id}"
end

# ---- 削除機能 ----

post '/article_delete' do
  login_required

  @post = Post.find(params[:post_id])
  page_num = @post.id
  @post.destroy

  # 最新記事を消した場合のみ、auto_incrementを修正
  if page_num == Post.count + 1
    ActiveRecord::Base.connection.execute("alter table posts auto_increment = #{page_num};")
  end

  redirect '/'
end

# ---- ログイン機能 ----

# login
get @login_path do
  slim :login, layout: nil
end

post '/login' do
  user = User.find_by(user_id: params[:user_id])

  # ユーザーが存在すればパスワードを比較する
  if user&.authenticate(params[:password])
    session[:user_id] = user.user_id
    redirect env_var('create_article_path')
  else
    slim :login, layout: nil
  end
end

delete '/logout' do
  login_required
  session.clear

  redirect env_var('login_path')
end

# ---- その他ルーティング ----

get '/profile' do
  slim :profile, layout: nil
end

get '/portfolio' do
  @page_name = 'portfolio'
  @title     = 'My Portfolio'
  slim :portfolio
end

not_found do
  slim :not_found
end
