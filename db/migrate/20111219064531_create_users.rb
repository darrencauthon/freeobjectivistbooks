class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :location
      t.string :school
      t.string :studying
      t.text :address

      t.timestamps
    end
  end
end
