class ChangeRequestCanceledToNonNull < ActiveRecord::Migration
  def up
    change_column :requests, :canceled, :boolean, null: false, default: false
  end

  def down
    change_column :requests, :canceled, :boolean
  end
end
