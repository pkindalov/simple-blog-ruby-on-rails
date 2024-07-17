class AddViewsCountToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :views_count, :integer, default: 0
  end
end
