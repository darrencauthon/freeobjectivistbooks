namespace :reminders do
  desc "Send reminders"
  task :send => :environment do
    ReminderJob.send_all_reminders
  end

  desc "Schedule reminders to be sent by a worker thread"
  task :schedule => :environment do
    ReminderJob.schedule_reminders
  end
end
