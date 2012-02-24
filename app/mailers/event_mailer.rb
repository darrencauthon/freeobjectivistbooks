class EventMailer < ApplicationMailer
  def self.mail_for_event(event)
    self.send "#{event.type}_event", event
  end

  def notification(subject, options = {})
    mail_to_user @event.to, options.merge(subject: subject)
  end

  def grant_event(event)
    @event = event
    @closer = "Happy reading"
    notification "We found a donor to send you #{@event.book}!"
  end

  def update_event(event)
    @event = event
    notification "#{@event.user.name} #{@event.detail} on Free Objectivist Books"
  end

  def flag_event(event)
    @event = event
    notification "Problem with your shipping info on Free Objectivist Books"
  end

  def fix_event(event)
    @event = event
    action = event.detail || "responded to your flag"
    notification "#{@event.user.name} #{action} on Free Objectivist Books"
  end

  def message_event(event)
    @event = event
    message_type = event.is_thanks? ? "thank-you note for #{@event.book}" : "message on Free Objectivist Books"
    notification "#{@event.user.name} sent you a #{message_type}"
  end

  def update_status_event(event)
    @event = event
    @review = event.donation.review
    @closer = "Happy reading" if event.to_student? && event.donation.sent?
    notification "#{@event.user.name} has #{@event.detail} #{@event.book}", template_name: "#{@event.detail}_event"
  end

  def cancel_event(event)
    @event = event
    @closer = "Yours"
    notification "We need to find you a new donor for #{@event.book}"
  end
end
