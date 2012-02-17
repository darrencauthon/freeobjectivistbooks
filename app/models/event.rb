class Event < ActiveRecord::Base
  self.inheritance_column = 'class'  # anything other than "type", to let us use "type" for something else

  TYPES = %w{grant flag update message update_status cancel}

  belongs_to :request
  belongs_to :user
  belongs_to :donor, class_name: "User"
  belongs_to :donation

  validates_presence_of :request, :user, :type
  validates_inclusion_of :type, in: TYPES

  validates_presence_of :message, if: lambda {|e| e.type.in? %w{flag message cancel}}, message: "Please enter a message."
  validates_inclusion_of :public, in: [true, false], if: :is_thanks?, message: 'Please choose "Yes" or "No".'

  after_initialize :populate

  after_create :update_thanked
  after_create :log
  after_create :notify

  def populate
    unless id
      self.request ||= donation.request if donation
      self.donor = donation.user if donation
      self.donor ||= request.donor
      self.user ||= default_user
      self.detail ||= request.status if type == "update_status"
      self.happened_at ||= Time.now
    end
  end

  def default_user
    case type
    when "grant", "flag", "cancel" then donor
    when "update" then student
    when "update_status"
      case request.status
      when "sent" then donor
      when "received" then student
      end
    else
      student if is_thanks?
    end
  end

  # Derived attributes

  def student
    request.user
  end

  def from
    user
  end

  def from_student?
    from == student
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
    to_donor? ? donor : student
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

  def update_thanked
    request.update_attributes! thanked: true if is_thanks?
  end

  def log
    Rails.logger.info "Event: #{inspect}"
  end
end
