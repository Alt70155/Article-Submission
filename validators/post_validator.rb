class PostValidator < ActiveModel::Validator
  DEFAULT_MAX_IMG_CNT = 15
  ENABLE_EXTENSION_REGEXP = /.*\.(jpg|png|jpeg|gif)\z/
  MARKDOWN_IMAGE_TAG_REGEXP = /!\[\S*\]\(\S*\)/

  # 定数の可視性をprivateにする
  private_constant(:DEFAULT_MAX_IMG_CNT, :ENABLE_EXTENSION_REGEXP, :MARKDOWN_IMAGE_TAG_REGEXP)

  def validate(post)
    raise ActiveRecord::RecordInvalid 'img_files_in_articleプロパティが定義されていません。' unless defined?(post.img_files_in_article)

    img_tag_ct = post.body.scan(MARKDOWN_IMAGE_TAG_REGEXP).length
    return if img_tag_ct.zero? && post.img_files_in_article.nil? # 記事内画像タグも画像選択もない場合

    # 画像タグがあって画像選択されていない場合
    if img_tag_ct.positive? && post.img_files_in_article.nil?
      post.errors[:img_files_in_article] << '画像タグが存在しますが、画像ファイルが添付されていません。'
      return
    end

    post.errors[:img_files_in_article] << '画像ファイルが添付できる上限数を超えています。' if post.img_files_in_article.length > DEFAULT_MAX_IMG_CNT

    # 拡張子が正常なら0、一致しなければnilが入る
    enable_img_files_in_article = post.img_files_in_article.map { |img| img =~ ENABLE_EXTENSION_REGEXP }

    return post.errors[:img_files_in_article] << '添付された記事内画像ファイル数と画像タグの数が一致しません。' unless img_tag_ct == enable_img_files_in_article.length
    return post.errors[:img_files_in_article] << '添付された記事内画像ファイルに拡張子がjpg, jpeg, png, gifではないものがあります。' unless enable_img_files_in_article.all?
  end
end
