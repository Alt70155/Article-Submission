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
    # @post = Post.order('id DESC')
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

get '/category/:path' do
  @page_name = 'index'
  @category = Category.find_by(path: params[:path])

  if @category
    @title = @category.cate_name
    @post_by_category = Post.where(category_id: @category.id).order('id DESC')
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
    @title          = @post.title
    @other_articles = Post.order('id DESC').first(6)
    @description    = @post.body[0..120].gsub(/##/, '').gsub(/(\r\n?|\n)/, ' ')

    # 前後の記事を取得
    @prev_post = Post.find_by(id: @post.id - 1)
    @next_post = Post.find_by(id: @post.id + 1)

    if login?
      session[:page_number] = @post.id
      @edit_path = env_var(:edit_path)
    end

    slim :articles
  else
    slim :not_found
  end
end

# create_article
get @env_hash[:create_article_path] do
  login_required
  csrf_token_generate

  @category = Category.all
  slim :create_article, layout: nil
end

post '/article_post' do
  login_required

  @page_name = 'article'

  redirect env_var(:create_article_path) unless params[:csrf_token] == session[:csrf_token]

  # params[:file]がnilの場合、params[:file][:filename]で例外が発生する
  # prevから投稿する場合、画像は保存してあるのでparams[:pic_name]にファイル名を格納してそれを使う
  thumbnail_file = params[:file]

  # params[:pic_name]は修正に戻った場合でも空文字が入っているので
  # 直接判定には使えないので注意
  thumbnail_name =  if params[:pic_name] && params[:pic_name].length.positive?
                      params[:pic_name]
                    elsif thumbnail_file && thumbnail_file[:filename]
                      thumbnail_file[:filename].downcase
                    else
                      nil
                    end

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
    if thumbnail_file
      File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(thumbnail_file[:tempfile].read) }
      # webp形式に変換して保存
      system("cwebp ./public/img/#{@post.top_picture} -o ./public/img/#{@post.top_picture}.webp")
    end
    # 記事内画像があればそれも保存
    params[:article_img_files]&.each do |img|
      File.open("public/img/#{img[:filename]}", 'wb') { |f| f.write(img[:tempfile].read) }
    end

    session[:img_files_name_in_article] = nil

    redirect "/articles/#{@post.id}"
  else
    # プレビュー画面から修正に戻った場合
    if params[:back]
      if @post.top_picture && File.exist?("public/img/#{@post.top_picture}")
        File.delete("public/img/#{@post.top_picture}")
      end
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

  redirect env_var(:create_article_path) unless params[:csrf_token] == session[:csrf_token]

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

  if @post.top_picture
    File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(thumbnail_file[:tempfile].read) }
  end

  if @post.img_files_in_article
    # 修正に戻る場合、記事内画像を削除するためにセッションでファイル名を保持する
    session[:img_files_name_in_article] = params[:article_img_files].map do |img|
      File.open("public/img/#{img[:filename]}", 'wb') { |f| f.write(img[:tempfile].read) }
      img[:filename]
    end
  end

  slim :article_prev
end

# ---- 編集機能 ----

get @env_hash[:edit_path] do
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
  thumbnail = params[:thumbnail]
  if thumbnail.present?
    File.open("public/img/#{thumbnail[:filename]}", 'wb') { |f| f.write(thumbnail[:tempfile].read) }
    system("cwebp ./public/img/#{thumbnail[:filename]} -o ./public/img/#{thumbnail[:filename]}.webp")
    unless @post.update(top_picture: params[:thumbnail][:filename])
      redirect env_var(:edit_path)
    end
  end

  if params[:article_img_files].present?
    params[:article_img_files].each do |img|
      File.open("public/img/#{img[:filename]}", 'wb') { |f| f.write(img[:tempfile].read) }
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
get @env_hash[:login_path] do
  return redirect env_var(:create_article_path) unless session[:user_id].nil?
  slim :login, layout: nil
end

post '/login' do
  user = User.find_by(user_id: params[:user_id])

  # ユーザーが存在すればパスワードを比較する
  if user&.authenticate(params[:password])
    session[:user_id] = user.user_id
    redirect env_var(:create_article_path)
  else
    slim :login, layout: nil
  end
end

delete '/logout' do
  login_required
  session.clear

  redirect env_var(:login_path)
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

get @env_hash[:file_upload_path] do
  login_required
  csrf_token_generate

  @all_image_names = Dir.glob('public/img/*').map { |f| f.slice!(/public\/img\//);f }
  slim :file_upload, layout: nil
end

post '/file_upload' do
  login_required
  redirect '/' unless params[:csrf_token] == session[:csrf_token]

  File.open("public/img/#{params[:file][:filename]}", 'wb') { |f| f.write(params[:file][:tempfile].read) }
  redirect env_var(:file_upload_path)
end

post '/search_page' do
  login_required
  redirect '/' unless params[:csrf_token] == session[:csrf_token]

  @article = Post.find_by(id: params[:page_num])
  slim :search_page
end
