class ReminderMailer < ApplicationMailer
  def self.targets_for(type)
    case type.to_sym
    when :fulfill_pledge then Pledge.unfulfilled
    when :send_books then User.donors_with_unsent_books
    when :confirm_receipt then Donation.needs_receipt
    when :read_books then Donation.needs_reading
    else raise "Don't know who should get #{type} reminder"
    end
  end

  def self.send_reminder(type)
    targets = targets_for type
    send_campaign type, targets
  end

  def reminder_mail(subject)
    mail_to_user @user, subject: subject
  end

  def fulfill_pledge(pledge)
    @pledge = pledge
    @user = pledge.user
    @request_count = Request.not_granted.count
    subject = "Fulfill your pledge of #{pledge.quantity} books on Free Objectivist Books"
    Reminder.create! user: @user, type: :fulfill_pledge, subject: subject, pledges: [@pledge]
    reminder_mail subject
  end

  def send_books(user)
    @user = user
    @donations = user.donations.needs_sending
    @donation = @donations.first
    @single = @donations.size == 1
    subject = if @single
      "Have you sent #{@donation.book} to #{@donation.student.name} yet?"
    else
      "Have you sent your #{@donations.size} books to students from Free Objectivist Books yet?"
    end
    Reminder.create! user: @user, type: :send_books, subject: subject, donations: @donations
    mail = reminder_mail subject
  end

  def confirm_receipt(donation)
    @donation = donation
    @user = donation.student
    subject = "Have you received #{@donation.book} yet?"
    Reminder.create! user: @user, type: :confirm_receipt, subject: subject, donations: [@donation]
    reminder_mail subject
  end

  def read_books(donation)
    @donation = donation
    @user = donation.student
    @received_at = donation.received_at
    subject = "Have you finished reading #{@donation.book}?"
    Reminder.create! user: @user, type: :read_books, subject: subject, donations: [@donation]
    reminder_mail subject
  end
end
