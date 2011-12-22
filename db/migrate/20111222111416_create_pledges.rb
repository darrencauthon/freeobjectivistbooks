class CreatePledges < ActiveRecord::Migration
  def change
    create_table :pledges do |t|
      t.references :user
      t.integer :quantity
      t.text :reason

      t.timestamps
    end
    add_index :pledges, :user_id
  end
end
