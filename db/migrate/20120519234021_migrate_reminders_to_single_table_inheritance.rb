class MigrateRemindersToSingleTableInheritance < ActiveRecord::Migration
  def up
    execute "update reminders set type='Reminders::FulfillPledge'  where type='fulfill_pledge'"
    execute "update reminders set type='Reminders::SendBooks'      where type='send_books'"
    execute "update reminders set type='Reminders::ConfirmReceipt' where type='confirm_receipt'"
    execute "update reminders set type='Reminders::ReadBooks'      where type='read_books'"
  end

  def down
    execute "update reminders set type='fulfill_pledge'  where type='Reminders::FulfillPledge'"
    execute "update reminders set type='send_books'      where type='Reminders::SendBooks'"
    execute "update reminders set type='confirm_receipt' where type='Reminders::ConfirmReceipt'"
    execute "update reminders set type='read_books'      where type='Reminders::ReadBooks'"
  end
end
