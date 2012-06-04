class ReminderJob
  # This class exists to work around https://github.com/collectiveidea/delayed_job/issues/306

  TYPES = [
    Reminders::FulfillPledge,
    Reminders::SendBooks,
    Reminders::ConfirmReceipt,
    Reminders::ReadBooks,
  ]

  def self.send_all_reminders
    new.send_all_reminders
  end

  def self.schedule_reminders
    Delayed::Job.enqueue new
  end

  def logger
    @logger ||= Rails.logger
  end

  def send_reminders(type)
    method = type.type_name

    logger.info "Gathering #{method} reminders..."
    reminders = type.all_reminders

    logger.info "Filtering #{reminders.size} #{method} reminders..."
    reminders.select! {|reminder| reminder.can_send?}

    if reminders.any?
      logger.info "Sending #{reminders.size} #{method} reminders..."
      ReminderMailer.send_campaign method, reminders
      logger.info "Done with #{method} reminders"
    else
      logger.info "No #{method} reminders to send"
    end
  end

  def send_all_reminders
    logger.info "Sending all reminders..."
    TYPES.each {|type| send_reminders type}
    logger.info "All reminders sent"
  end

  def perform
    send_all_reminders
  end
end
