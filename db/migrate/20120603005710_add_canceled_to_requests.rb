class AddCanceledToRequests < ActiveRecord::Migration
  def change
    change_table :requests do |t|
      t.boolean :canceled
    end
  end
end
