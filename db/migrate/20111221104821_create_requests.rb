class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :user
      t.string :book
      t.text :reason

      t.timestamps
    end
    add_index :requests, :user_id
  end
end
