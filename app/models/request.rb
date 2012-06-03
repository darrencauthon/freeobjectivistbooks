class Request < ActiveRecord::Base
  BOOKS = [
    "Atlas Shrugged",
    "The Fountainhead",
    "We the Living",
    "The Virtue of Selfishness",
    "Capitalism: The Unknown Ideal",
    "Objectivism: The Philosophy of Ayn Rand",
  ]

  BOOK_NOTES = {
    "Atlas Shrugged" => "(start here if you don't know what to choose!)",
    "Objectivism: The Philosophy of Ayn Rand" => "(by Leonard Peikoff)",
  }

  attr_accessor :other_book

  # Associations

  belongs_to :user, autosave: true
  belongs_to :donation
  has_many :donations, dependent: :destroy
  has_many :events, dependent: :destroy
  belongs_to :referral

  Event::TYPES.each do |type|
    define_method "#{type}_events" do
      events.scoped_by_type type
    end
  end

  # Validations

  validates_presence_of :book, message: "Please choose a book."
  validates_presence_of :reason, message: "This is required."
  validates_acceptance_of :pledge, message: "You must pledge to read this book.", allow_nil: false, on: :create
  validates_presence_of :address, if: :address_required?, message: "We need your address to send you your book."

  # Scopes

  default_scope order("created_at desc")

  scope :active, where(canceled: false)
  scope :canceled, where(canceled: true)

  scope :granted, active.where('donation_id is not null')
  scope :not_granted, active.where(donation_id: nil)

  # Callbacks

  after_initialize do |request|
    request.book = "Atlas Shrugged" if request.book.blank?
  end

  before_validation do |request|
    request.book = request.other_book if request.book == "other"
  end

  # Derived attributes

  delegate :address, :address=, to: :user
  delegate :name, :name=, to: :user, prefix: true
  delegate :thanked?, :sent?, :in_transit?, :received?, :reading?, :read?, :can_send?, :can_flag?, :flagged?, :review,
    :flag_message, :next_status, :needs_fix?, to: :donation, allow_nil: true

  def student
    user
  end

  def donor
    donation && donation.user
  end

  def active?
    !canceled?
  end

  def granted?
    donation.present?
  end

  def open?
    !granted?
  end

  def address_required?
    granted? && !flagged?
  end

  def needs_thanks?
    granted? && !thanked?
  end

  def status
    donation ? donation.status : ActiveSupport::StringInquirer.new("")
  end

  def can_update?
    active? && !sent?
  end

  def can_cancel?
    !sent? && !canceled?
  end

  # Actions

  def grant(user)
    self.donation = donations.build(user: user, flagged: address.blank?) unless donation && donor == user
    event = donation.grant_events.last unless donation.new_record?
    event || grant_events.build(donation: donation)
  end

  def build_update_event
    update_events.build detail: user.update_detail if user.changed?
  end

  def cancel(params = {})
    return if canceled?
    raise "Can't cancel" if !can_cancel?

    self.canceled = true
    donation.canceled = true if donation
    cancel_request_events.build params[:event]
  end
end
