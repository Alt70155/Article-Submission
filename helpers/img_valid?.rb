require 'sinatra/reloader'

helpers do
  MAX_IMG_CNT = 10
  def img_valid?(body, img_files)
    img_tag_ct = body.scan(/!\[\S*\]\(\S*\)/).length
    # 画像タグも画像もない場合
    return true if img_tag_ct.zero? && img_files.nil?

    # 画像タグがあって画像がない場合
    return false if img_tag_ct.positive? && img_files.nil?

    # 拡張子は正しいか・画像タグと画像数が同じかをチェック
    ary = img_files.map { |img| img[:filename] =~ /.*\.(jpg|png|jpeg)\z/ }
    img_tag_ct == img_files.length && img_files.length < MAX_IMG_CNT && ary.all?
  end
end
