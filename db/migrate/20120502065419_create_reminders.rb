class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.references :user
      t.string :type
      t.string :subject

      t.timestamps
    end
    add_index :reminders, :user_id
  end
end
