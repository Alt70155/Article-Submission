class PostValidator < ActiveModel::Validator
  DEFAULT_MAX_IMG_CNT = 10
  ENABLE_EXTENSION_REGEXP = /.*\.(jpg|png|jpeg)\z/
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

    # image_count = options.image_count || DEFAULT_MAX_IMG_CNT
    # 拡張子が正しいか、画像タグと画像数が同じかをチェック
    if post.img_files_in_article[0].is_a?(Hash)
      enable_img_files_in_article = post.img_files_in_article.map { |img| img[:filename] =~ ENABLE_EXTENSION_REGEXP }
    else
      enable_img_files_in_article = post.img_files_in_article.map { |img| img =~ ENABLE_EXTENSION_REGEXP }
    end

    post.errors[:img_files_in_article] << '添付された画像ファイル数と画像タグの数が一致しません。' unless img_tag_ct == enable_img_files_in_article.length && enable_img_files_in_article.all?
  end
end
