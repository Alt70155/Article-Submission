class Post < ActiveRecord::Base
  validates_presence_of :title, :body, :top_picture # 値が空じゃないか
  validates :title, length: { in: 1..75 }
  validates :body,  length: { in: 1..20000 }
  validates :top_picture, format: { with: /.*\.(jpg|png|jpeg)\z/,
                                    message: "is only jpg, jpeg, png" }
  # before_validation :file_check # save直前に実行される

  private
  # private
end
