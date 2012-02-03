class EventMailer < ApplicationMailer
  def self.mail_for_event(event)
    self.send "#{event.type}_event", event
  end

  def notification(subject)
    mail_to_user @event.to, subject: subject
  end

  def grant_event(event)
    @event = event
    @closer = "Happy reading"
    notification "We found a donor to send you #{@event.request.book}!"
  end

  def flag_event(event)
    @event = event
    notification "Problem with your shipping info on Free Objectivist Books"
  end

  def update_event(event)
    @event = event
    notification "#{@event.user.name} #{@event.detail} on Free Objectivist Books"
  end

  def message_event(event)
    @event = event
    notification "#{@event.user.name} sent you a message on Free Objectivist Books"
  end

  def update_status_event(event)
    @event = event
    @closer = "Happy reading"
    notification "#{@event.user.name} has #{@event.detail} #{@event.request.book}"
  end

  def thank_event(event)
    @event = event
    notification "#{@event.user.name} sent you a thank-you note for #{@event.request.book}"
  end

  def cancel_event(event)
    @event = event
    @closer = "Yours"
    notification "We need to find you a new donor for #{@event.request.book}"
  end
end
