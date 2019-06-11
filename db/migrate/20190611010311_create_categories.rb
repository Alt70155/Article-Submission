class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories, id: false do |t|
      t.column :category_id, 'INTEGER PRIMARY KEY AUTO_INCREMENT'
      t.string :cate_name, null: false
    end
  end
end
