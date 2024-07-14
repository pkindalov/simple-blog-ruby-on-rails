class RemoveStringFromPosts < ActiveRecord::Migration[7.1]
  def change
    remove_column :posts, :string, :string
  end
end
