class ChangeEventsFromThankTypeToBit < ActiveRecord::Migration
  def up
    add_column :events, :is_thanks, :boolean
    execute "update events set type='message', is_thanks=true where type='thank'"
  end

  def down
    execute "update events set type='thank' where is_thanks"
    remove_column :events, :is_thanks
  end
end
