class CreateUser < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :user_image_url
      t.timestamps null: false
    end
  end
end
