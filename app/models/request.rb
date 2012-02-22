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
  has_many :donations
  has_many :events

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

  scope :open, where(donation_id: nil)
  scope :granted, where('donation_id is not null')

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
  delegate :thanked?, :sent?, :in_transit?, :received?, :can_send?, :can_flag?, :flagged?, :flag_message, to: :donation, allow_nil: true

  def student
    user
  end

  def donor
    donation && donation.user
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

  # Actions

  def grant(user)
    donation = donations.build user: user, flagged: address.blank?
    donation.save!

    update_attributes! donation: donation

    event = donation.grant_events.build
    event.save!

    donation
  end

  def build_update_event
    update_events.build detail: user.update_detail if user.changed?
  end
end
