class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :request
      t.references :user
      t.references :donor
      t.string :type
      t.string :detail
      t.text :message
      t.datetime :happened_at
      t.datetime :notified_at

      t.timestamps
    end
    add_index :events, :request_id
    add_index :events, :user_id
    add_index :events, :donor_id
  end
end
