class Donation < ActiveRecord::Base
  belongs_to :request
  belongs_to :user
  has_many :events

  delegate :book, :address, to: :request

  scope :active, where(canceled: false)
  scope :canceled, where(canceled: true)

  scope :flagged, active.where(flagged: true)
  scope :not_flagged, active.where(flagged: false)

  scope :not_sent, active.scoped_by_status("not_sent")
  scope :sent, active.scoped_by_status(%w{sent received})
  scope :received, active.scoped_by_status("received")

  scope :needs_sending, active.not_flagged.not_sent

  # Derived attributes

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
end
