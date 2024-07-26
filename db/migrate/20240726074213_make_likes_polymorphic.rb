# frozen_string_literal: true

class MakeLikesPolymorphic < ActiveRecord::Migration[7.1]
  def change
    remove_index :likes, :post_id
    remove_column :likes, :post_id, :integer
    add_reference :likes, :likeable, polymorphic: true, index: true
  end
end
