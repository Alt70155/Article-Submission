class Post < ActiveRecord::Base
  attr_accessor :img_files_in_article

  ENABLE_EXTENSION_REGEXP = /.*\.(jpg|png|jpeg)\z/

  validates :category_id, presence: true, numericality: { only_integer: true }
  validates :title, length: { in: 1..75 }
  validates :body,  length: { in: 1..20000 }
  validates :top_picture, presence: true,
            format: { with: ENABLE_EXTENSION_REGEXP, message: 'is only jpg, jpeg, png' }
  # validates_withヘルパーは、バリデーション専用の別クラスにレコードを渡す
  validates_with PostValidator
end
