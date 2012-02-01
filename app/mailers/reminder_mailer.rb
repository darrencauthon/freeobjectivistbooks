class ReminderMailer < ApplicationMailer
  def self.targets_for(reminder)
    case reminder.to_sym
    when :fulfill_pledge then Pledge.unfulfilled
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

  def reminder(subject)
    mail_to_user @user, subject: subject
  end

  def fulfill_pledge(pledge)
    @pledge = pledge
    @user = pledge.user
    @request_count = Request.open.count
    reminder "Fulfill your pledge of #{pledge.quantity} books on Free Objectivist Books"
  end
end
