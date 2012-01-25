class EventMailer < ApplicationMailer
  def self.mail_for_event(event)
    self.send "#{event.type}_event", event
  end

  def grant_event(event)
    @event = event
    mail_to_user @event.to, subject: "We found a donor to send you #{@event.request.book}!"
  end

  def flag_event(event)
    @event = event
    mail_to_user @event.to, subject: "Problem with your shipping info on Free Objectivist Books"
  end

  def update_event(event)
    @event = event
    mail_to_user @event.to, subject: "#{@event.user.name} #{@event.detail} on Free Objectivist Books"
  end

  def message_event(event)
    @event = event
    mail_to_user @event.to, subject: "#{@event.user.name} sent you a message on Free Objectivist Books"
  end

  def thank_event(event)
    @event = event
    mail_to_user @event.to, subject: "#{@event.user.name} sent you a thank-you note for #{@event.request.book}"
  end
end
