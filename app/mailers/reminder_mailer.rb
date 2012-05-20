class ReminderMailer < ApplicationMailer
  def self.send_reminders(type)
    method = type.type_name
    Rails.logger.info "Gathering #{method} reminders..."
    reminders = type.all_reminders
    Rails.logger.info "Filtering #{reminders.size} #{method} reminders..."
    reminders.select! {|reminder| reminder.can_send?}

    if reminders.any?
      Rails.logger.info "Sending #{reminders.size} #{method} reminders..."
      send_campaign method, reminders
      Rails.logger.info "Done with #{method} reminders"
    else
      Rails.logger.info "No #{method} reminders to send"
    end
  end

  def self.send_all_reminders
    Rails.logger.info "Sending all reminders..."
    Reminder::TYPES.each {|type| send_reminders type}
    Rails.logger.info "All reminders sent"
  end

  def self.send_to_target(method, reminder)
    return if !reminder.can_send?
    mail = super
    reminder.subject = mail.subject
    reminder.save!
    mail
  end

  def reminder_mail(subject)
    mail_to_user @user, subject: subject
  end

  # Reminder types

  def fulfill_pledge(reminder)
    @user = reminder.user
    @pledge = reminder.pledge
    @request_count = Request.not_granted.count
    reminder_mail "Fulfill your pledge of #{@pledge.quantity} Objectivist books"
  end

  def send_books(reminder)
    @user = reminder.user
    @donations = reminder.donations
    @donation = @donations.first
    @single = @donations.size == 1
    subject = if @single
      "Have you sent #{@donation.book} to #{@donation.student.name} yet?"
    else
      "Have you sent your #{@donations.size} Objectivist books to students yet?"
    end
    reminder_mail subject
  end

  def confirm_receipt(reminder)
    @user = reminder.user
    @donation = reminder.donation
    reminder_mail "Have you received #{@donation.book} yet?"
  end

  def read_books(reminder)
    @user = reminder.user
    @donation = reminder.donation
    @received_at = @donation.received_at
    reminder_mail "Have you finished reading #{@donation.book}?"
  end
end
