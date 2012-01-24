class AddThankYouFields < ActiveRecord::Migration
  def change
    add_column :requests, :thanked, :boolean
    add_column :events, :public, :boolean
  end
end
