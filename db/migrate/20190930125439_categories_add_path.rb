class CategoriesAddPath < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :path, :string
  end
end
