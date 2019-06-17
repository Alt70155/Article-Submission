class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :user_id, null: false
      t.string :password_digest, null: false

      t.timestamps
      t.index :user_id, unique: true
    end
  end
end
