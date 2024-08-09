class CreateReactions < ActiveRecord::Migration[7.1]
  def change
    create_table :reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reactionable, polymorphic: true, null: false
      t.string :reaction_type, null: false

      t.timestamps
    end
  end
end
