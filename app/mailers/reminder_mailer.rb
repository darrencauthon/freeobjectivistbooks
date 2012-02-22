class ReminderMailer < ApplicationMailer
  def self.targets_for(reminder)
    case reminder.to_sym
    when :fulfill_pledge then Pledge.unfulfilled
    when :send_books then User.donors_with_unsent_books
    when :confirm_receipt then Donation.needs_receipt
    else raise "Don't know who should get #{reminder} reminder"
    end
  end

  def self.send_reminder(reminder)
    targets_for(reminder).each do |target|
      mail = self.send reminder, target
      Rails.logger.info "Sending #{reminder} to #{mail.to}"
      mail.deliver
    end
  end

  def reminder(subject, options = {})
    mail_to_user @user, options.merge(subject: subject)
  end

  def fulfill_pledge(pledge)
    @pledge = pledge
    @user = pledge.user
    @request_count = Request.open.count
    reminder "Fulfill your pledge of #{pledge.quantity} books on Free Objectivist Books"
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
    mail = reminder subject, 'X-Mailgun-Campaign-ID' => 'send_books-2012_02_21'
  end

  def confirm_receipt(donation)
    @donation = donation
    @user = donation.student
    reminder "Have you received #{@donation.book} yet?", 'X-Mailgun-Campaign-ID' => "confirm_receipt-2012_02_21"
  end
end
