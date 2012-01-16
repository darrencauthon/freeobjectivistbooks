class EventMailer < ActionMailer::Base
  default from: "jason@rationalegoist.com"

  def self.mail_for_event(event)
    self.send event.type, event
  end

  def updated(event)
    @event = event
    mail to: @event.to.email, subject: "#{@event.user.name} #{@event.detail} on Free Objectivist Books"
  end

  def messaged(event)
    @event = event
    mail to: @event.to.email, subject: "#{@event.user.name} sent you a message on Free Objectivist Books"
  end
end
