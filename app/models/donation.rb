class Donation < ActiveRecord::Base
  # Associations

  belongs_to :request
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
  validates_inclusion_of :status, in: %w{not_sent sent received}

  # Scopes

  scope :active, where(canceled: false)
  scope :canceled, where(canceled: true)

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

  delegate :book, :address, to: :request

  def active?
    !canceled?
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

  # Actions

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
end
