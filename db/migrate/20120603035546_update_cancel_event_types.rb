class UpdateCancelEventTypes < ActiveRecord::Migration
  def up
    execute "update events set type='cancel_donation' where type='cancel'"
  end

  def down
    execute "update events set type='cancel' where type='cancel_donation'"
  end
end
