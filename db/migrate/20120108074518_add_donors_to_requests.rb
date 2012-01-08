class AddDonorsToRequests < ActiveRecord::Migration
  def change
    change_table :requests do |t|
      t.references :donor
    end
  end
end
