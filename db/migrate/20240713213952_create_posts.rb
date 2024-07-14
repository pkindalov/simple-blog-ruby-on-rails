class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :description
      t.date :post_date
      t.string :photo
      t.string :string

      t.timestamps
    end
  end
end
