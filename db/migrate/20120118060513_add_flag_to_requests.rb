class AddFlagToRequests < ActiveRecord::Migration
  def change
    change_table :requests do |t|
      t.boolean :flagged
    end
  end
end
