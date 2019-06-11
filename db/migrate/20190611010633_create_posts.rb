class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t| # postsがテーブル名
      t.integer :category_id, foreign_key: true # 型をcategory_idと合わせる
      t.string  :title, null: false # stringはVARCHAR(255)
      t.text    :body,  null: false
      t.string  :top_picture, null: false
      t.timestamps # これでcreate_atとupdate_atカラムが定義される
    end
  end
end
