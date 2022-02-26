class CreatePostTable < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :music
      t.string :artist
      t.string :album
      t.string :sample
      t.string :image_url
      t.integer :user_id
      t.string :comment
      t.timestamps null: false
    end
  end
end
