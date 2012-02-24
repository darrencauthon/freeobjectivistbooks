class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :user
      t.string :book
      t.text :text
      t.boolean :recommend
      t.references :donation

      t.timestamps
    end
    add_index :reviews, :user_id
    add_index :reviews, :donation_id
  end
end
