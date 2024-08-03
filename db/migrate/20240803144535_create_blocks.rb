class CreateBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :blocks do |t|
      t.integer :blocker_id
      t.integer :blocked_id

      t.timestamps
    end
    add_index :blocks, :blocker_id
    add_index :blocks, :blocked_id
    add_index :blocks, [:blocker_id, :blocked_id], unique: true
  end
end
