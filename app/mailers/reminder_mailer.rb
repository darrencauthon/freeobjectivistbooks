class ReminderMailer < ApplicationMailer
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
