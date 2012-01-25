class AnnouncementMailer < ApplicationMailer
  def self.send_announcements(announcement, targets)
    targets.each {|target| send_announcement announcement, target}
  end

  def self.send_announcement(announcement, target)
    mail = self.send announcement, target
    Rails.logger.info "Sending #{announcement} to #{mail.to}"
    mail.deliver
  end

  def thank_your_donor(request)
    @request = request
    mail_to_user @request.user, subject: "Thank your donor for #{@request.book}"
  end
end
