class PasswordChangeColumnToText < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :password_digest, :text
  end
end
