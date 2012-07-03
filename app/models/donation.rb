class Donation < ActiveRecord::Base
  # Associations

  belongs_to :request, autosave: true
  belongs_to :user
  has_many :events, dependent: :destroy
  has_one :review
  has_many :reminder_entities, as: :entity
  has_many :reminders, through: :reminder_entities

  Event::TYPES.each do |type|
    define_method "#{type}_events" do
      events.scoped_by_type type
    end
  end

  # Validations

  validates_presence_of :request
  validates_presence_of :user
  validates_presence_of :address, unless: :flagged?, message: "We need your address to send you your book."
  validates_inclusion_of :status, in: %w{not_sent sent received read}
  validates_uniqueness_of :request_id, scope: :canceled, if: :active?, message: "has already been granted", on: :create
  validate :donor_cannot_be_requester, on: :create

  def donor_cannot_be_requester
    errors.add :base, "You can't donate to yourself!" if donor == student
  end

  # Scopes

  default_scope order("created_at desc")

  scope :active, where(canceled: false)
  scope :canceled, where(canceled: true)

  scope :thanked, active.where(thanked: true)
  scope :not_thanked, active.where(thanked: false)

  scope :flagged, active.where(flagged: true)
  scope :not_flagged, active.where(flagged: false)

  scope :not_sent, active.scoped_by_status("not_sent")
  scope :sent, active.scoped_by_status(%w{sent received read})
  scope :in_transit, active.scoped_by_status("sent")
  scope :received, active.scoped_by_status(%w{received read})
  scope :reading, active.scoped_by_status("received")
  scope :read, active.scoped_by_status("read")

  scope :needs_sending, active.not_flagged.not_sent
  scope :needs_thanks, active.received.not_thanked

  # Callbacks

  before_validation do |donation|
    if donation.status.blank?
      donation.status = "not_sent"
      donation.status_updated_at = donation.created_at
    end
  end

  # Derived attributes

  delegate :book, to: :request
  delegate :address, :address=, to: :student
  delegate :name, :name=, to: :student, prefix: true

  def active?
    !canceled?
  end

  def donor
    user
  end

  def student
    request.user
  end

  def status
    ActiveSupport::StringInquirer.new(self[:status] || "")
  end

  def sent?
    status.sent? || status.received? || status.read?
  end

  def in_transit?
    status.sent?
  end

  def received?
    status.received? || status.read?
  end

  def reading?
    status.received?
  end

  def read?
    status.read?
  end

  def needs_fix?
    active? && flagged?
  end

  def can_send?
    !sent? && !flagged?
  end

  def can_flag?
    !sent? && !flagged?
  end

  def donor_can_cancel?
    !received?
  end

  def student_can_cancel?
    return false if sent? || flagged? || Time.since(created_at) < 3.weeks
    reminder = reminders.where(type: Reminders::SendBooks).reorder(:created_at).first
    reminder && Time.since(reminder.created_at) >= 1.week
  end

  def can_cancel?(user)
    case user
    when donor then donor_can_cancel?
    when student then student_can_cancel?
    else false
    end
  end

  def flag_message
    event = flag_events.last
    event.message if event
  end

  def updated_at_for_status(status)
    return created_at if status == "not_sent"

    event = update_status_events.where(detail: status).last
    if event
      event.happened_at
    elsif self.status == status
      updated_at
    end
  end

  def sent_at
    updated_at_for_status "sent"
  end

  def received_at
    updated_at_for_status "received"
  end

  def read_at
    updated_at_for_status "read"
  end

  # Actions

  def update_status(params, time = Time.now)
    self.status = params[:status]
    self.status_updated_at = time

    event_attributes = params[:event] || {}
    event = update_status_events.build event_attributes.merge(detail: params[:status])
    if event.message.blank?
      event.is_thanks = nil
      event.public = nil
    end
    event
  end

  def flag(params)
    self.flagged = true
    flag_events.build params
  end

  def fix(attributes, event_attributes = {})
    self.attributes = attributes
    self.flagged = false
    fix_events.build event_attributes.merge(detail: student.update_detail)
  end

  def cancel(params, user)
    return if canceled?
    raise "Can't cancel" unless can_cancel? user
    self.canceled = true
    if request.donation == self
      request.donation = nil
      cancel_donation_events.build params[:event].merge(user: user)
    end
  end
end
