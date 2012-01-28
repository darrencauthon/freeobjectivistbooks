class Event < ActiveRecord::Base
  self.inheritance_column = 'class'  # anything other than "type", to let us use "type" for something else

  TYPES = %w{grant flag update message thank}

  belongs_to :request
  belongs_to :user
  belongs_to :donor, class_name: "User"

  validates_presence_of :request, :user, :type
  validates_inclusion_of :type, in: TYPES

  validates_presence_of :message, if: lambda {|e| e.type.in? %w{flag message thank}}, message: "Please enter a message."
  validates_inclusion_of :public, in: [true, false], if: lambda {|e| e.type == "thank"}, message: 'Please choose "Yes" or "No".'

  after_initialize :populate

  after_create :log
  after_create :notify

  def populate
    unless id
      self.donor = request.donor
      self.user ||= default_user
      self.happened_at ||= Time.now
    end
  end

  def default_user
    case type
    when "grant", "flag" then request.donor
    when "update", "thank" then request.user
    end
  end

  def self.create_event!(request, user, type, options = {})
    attributes = {request: request, user: user, donor: request.donor, type: type, happened_at: Time.now}
    attributes.merge! options
    event = create! attributes
    event
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

  def self.create_message!(request, user, message)
    create_event! request, user, "message", message: message
  end

  # Derived attributes

  def from
    user
  end

  def from_student?
    from == request.user
  end

  def from_donor?
    from == donor
  end

  def to_donor?
    from_student?
  end

  def to_student?
    from_donor?
  end

  def to
    to_donor? ? donor : request.user
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
    Rails.logger.info "Sending notification for event #{id} (#{type} #{detail}) to #{to.name} (#{to.email})"
    mail = EventMailer.mail_for_event self
    mail.deliver
    self.notified!
  end

  def log
    Rails.logger.info "Event: #{inspect}"
  end
end
