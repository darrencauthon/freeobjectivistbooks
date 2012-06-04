class Event < ActiveRecord::Base
  self.inheritance_column = 'class'  # anything other than "type", to let us use "type" for something else

  TYPES = %w{grant update flag fix message update_status cancel_donation cancel_request}

  # Associations

  belongs_to :request
  belongs_to :user
  belongs_to :donation

  # Validations

  validates_presence_of :request, :user, :type
  validates_presence_of :donation, if: lambda {|e| e.type.in? %w{grant flag fix message update_status cancel_donation}}
  validates_inclusion_of :type, in: TYPES

  validates_presence_of :message, if: :requires_message?, message: "Please enter a message."
  validates_inclusion_of :public, in: [true, false], if: :is_thanks?, message: 'Please choose "Yes" or "No".'
  validate :message_or_detail_must_be_present, if: lambda {|e| e.type == "fix" && e.request.address.present?}

  def requires_message?
    case type
    when "flag", "message" then true
    when "cancel_donation" then detail != "not_received"
    else false
    end
  end

  def message_or_detail_must_be_present
    if detail.blank? && message.blank?
      errors[:message] << "If you don't need to update your shipping info, please enter a message for your donor."
    end
  end

  # Scopes

  default_scope order(:happened_at)

  scope :reverse_order, reorder('happened_at desc')

  # Callbacks

  after_initialize :populate

  after_create :update_thanked
  after_create :log
  after_create :notify

  def populate
    unless id
      self.donation ||= request.donation if request
      self.request ||= donation.request if donation
      self.user ||= default_user
      self.happened_at ||= Time.now
    end
  end

  def default_user
    case type
    when "grant", "flag" then donor
    when "update", "fix", "cancel_request" then student
    when "update_status"
      case detail
      when "sent" then donor
      when "received", "read" then student
      end
    else
      student if is_thanks?
    end
  end

  # Derived attributes

  delegate :book, to: :request

  def student
    request.user
  end

  def donor
    donation && donation.user
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
    donation.update_attributes! thanked: true if is_thanks?
  end

  def log
    Rails.logger.info "Event: #{inspect}"
  end
end
