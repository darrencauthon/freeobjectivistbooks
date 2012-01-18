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

  belongs_to :user
  belongs_to :donor, class_name: "User"
  has_many :events

  validates_presence_of :book, message: "Please choose a book."
  validates_presence_of :reason, message: "This is required."
  validates_acceptance_of :pledge, message: "You must pledge to read this book.", allow_nil: false, on: :create

  scope :open, where(donor_id: nil).order(:created_at)
  scope :granted, where('donor_id is not null').order(:created_at)

  after_initialize do |request|
    request.book = "Atlas Shrugged" if request.book.blank?
  end

  before_validation do |request|
    request.book = request.other_book if request.book == "other"
  end

  def granted?
    donor.present?
  end

  def open?
    !granted?
  end

  def update_user(attributes, message = nil)
    user.attributes = attributes
    return :error if user.invalid?

    event = if user.changed?
      Event.create_update! self, message
    elsif message.present?
      Event.create_message! self, user, message
    end
    Rails.logger.info "event: #{event.inspect}"

    user.save!
    event.type.to_sym if event
  end
end
