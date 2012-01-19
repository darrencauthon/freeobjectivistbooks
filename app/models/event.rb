class Event < ActiveRecord::Base
  self.inheritance_column = 'class'  # anything other than "type", to let us use "type" for something else

  belongs_to :request
  belongs_to :user
  belongs_to :donor, class_name: "User"

  validates_presence_of :request, :user, :type
  validates_inclusion_of :type, in: %w{grant flag update message}

  validates_presence_of :message, if: "type == 'message'"

  after_create :notify

  def self.create_event!(request, user, type, options = {})
    attributes = {request: request, user: user, donor: request.donor, type: type, happened_at: Time.now}
    attributes.merge! options
    create! attributes
  end

  def self.create_grant!(request, options = {})
    create_event! request, request.donor, "grant", options
  end

  def self.create_update!(request, message = nil)
    user = request.user
    detail = if user.address_was.blank? && user.address.present?
      "added a shipping address"
    elsif user.name_was.words.size < 2 && user.name.words.size >= 2
      "added their full name"
    elsif user.name_changed? || user.address_changed?
      "updated shipping info"
    else
      raise "Tried to make update event for request with no name/address change; user.changes: #{user.changes.inspect}"
    end

    create_event! request, user, "update", detail: detail, message: message
  end

  def self.create_flag!(request, message)
    create_event! request, request.donor, "flag", message: message
  end

  def self.create_message!(request, user, message)
    create_event! request, user, "message", message: message
  end

  # Derived attributes

  def to
    user == request.user ? donor : request.user
  end

  def to_donor?
    to == donor
  end

  def to_student?
    to == request.user
  end

  def notified?
    notified_at.present?
  end

  # Actions

  def notified
    self.notified_at = Time.now
  end

  def notified!
    notified
    save!
  end

  def notify
    return if !to || notified?
    mail = EventMailer.mail_for_event self
    mail.deliver
    self.notified!
  end
end
