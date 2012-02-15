class AnnouncementMailer < ApplicationMailer
  def self.send_announcement(announcement, targets)
    targets.each do |target|
      mail = self.send announcement, target
      Rails.logger.info "Sending #{announcement} to #{mail.to}"
      mail.deliver
    end
  end

  def announcement(subject)
    mail_to_user @user, subject: subject
  end

  def thank_your_donor(request)
    @request = request
    @user = @request.user
    announcement "Thank your donor for #{@request.book}"
  end

  def reply_to_thanks(event)
    @event = event
    @user = @event.donor
    announcement "Now you can reply to #{@event.from.name}'s thank-you note on Free Objectivist Books"
  end

  def mark_sent_books(user)
    @user = user
    @count = user.donations.count
    announcement "Have you sent your Objectivist books? Let me and the students know"
  end

  def mark_received_books(request)
    @request = request
    @user = request.user
    @sent_event = request.update_status_events.where(detail: "sent").last
    announcement "Have you received #{request.book}? Let us and your donor know"
  end
end
