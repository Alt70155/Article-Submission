class Post < ActiveRecord::Base
  ENABLE_EXTENSION_REGEXP = /.*\.(jpg|png|jpeg)\z/
  validates :category_id, presence: true, numericality: { only_integer: true }
  validates :title, length: { in: 1..75 }
  validates :body,  length: { in: 1..20000 }
  validates :top_picture, presence: true,
                          format: { with: ENABLE_EXTENSION_REGEXP,
                                    message: 'is only jpg, jpeg, png' }
  # before_validation :method_name # save直前に実行される

  private
  # private
end
