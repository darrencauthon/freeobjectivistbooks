class Donation < ActiveRecord::Base
  # Associations

  belongs_to :request, autosave: true
  belongs_to :user
  has_many :events

  Event::TYPES.each do |type|
    define_method "#{type}_events" do
      events.scoped_by_type type
    end
  end

  # Validations

  validates_presence_of :request
  validates_presence_of :user
  validates_presence_of :address, unless: :flagged?, message: "We need your address to send you your book."
  validates_inclusion_of :status, in: %w{not_sent sent received}

  # Scopes

  scope :active, where(canceled: false)
  scope :canceled, where(canceled: true)

  scope :thanked, active.where(thanked: true)
  scope :not_thanked, active.where(thanked: false)

  scope :flagged, active.where(flagged: true)
  scope :not_flagged, active.where(flagged: false)

  scope :not_sent, active.scoped_by_status("not_sent")
  scope :sent, active.scoped_by_status(%w{sent received})
  scope :received, active.scoped_by_status("received")

  scope :needs_sending, active.not_flagged.not_sent

  # Callbacks

  before_validation do |donation|
    donation.status = "not_sent" if donation.status.blank?
  end

  after_save :update_request_for_cancel_if_needed

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
    status.sent? || status.received?
  end

  def received?
    status.received?
  end

  def can_send?
    !sent? && !flagged?
  end

  def can_flag?
    !sent? && !flagged?
  end

  def can_cancel?
    !sent?
  end

  def flag_message
    event = flag_events.order('created_at desc').first
    event.message if event
  end

  # Actions

  def update_status(params)
    self.status = params[:status]
    return unless changed?
    save!

    if request.donation == self
      request.status = status
      request.save!
    end

    event = update_status_events.build (params[:event] || {})
    if event.message.blank?
      event.is_thanks = nil
      event.public = nil
    end
    event.save!
    event
  end

  def flag(params)
    self.flagged = true
    flag_events.build params
  end

  def fix(attributes, event_attributes = {})
    self.attributes = attributes
    self.flagged = false
    request.flagged = false

    event = events.build event_attributes
    event.user = student
    event.type = student.changed? ? "update" : "message"
    event.detail = student.update_detail
    event
  end

  def cancel(params)
    return if canceled?
    self.canceled = true
    cancel_events.build params[:event]
  end

  def update_request_for_cancel_if_needed
    if canceled? && request.donation == self
      request.donation = nil
      request.donor = nil
      request.status = nil
      request.thanked = false
      request.flagged = false
      request.save!
    end
  end
  # Metrics

  def self.metrics
    calculate_metrics [
      {name: 'Active',   value: active.count},
      {name: 'Flagged',  value: flagged.count,  denominator: 'Active'},
      {name: 'Thanked',  value: thanked.count,  denominator: 'Active'},
      {name: 'Canceled', value: canceled.count, denominator: 'Total'},
      {name: 'Total',    value: count},
    ]
  end
end
