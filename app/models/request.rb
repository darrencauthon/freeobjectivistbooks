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

  scope :open, where(donor_id: nil)
  scope :granted, where('donor_id is not null')
  scope :flagged, where(flagged: true)
  scope :thanked, where(thanked: true)

  Event::TYPES.each do |type|
    define_method "#{type}_events" do
      events.scoped_by_type type
    end
  end

  after_initialize do |request|
    request.book = "Atlas Shrugged" if request.book.blank?
  end

  before_validation do |request|
    request.book = request.other_book if request.book == "other"
  end

  # Derived attributes

  def address
    user.address
  end

  def granted?
    donor.present?
  end

  def needs_thanks?
    granted? && !thanked?
  end

  def open?
    !granted?
  end

  def status
    ActiveSupport::StringInquirer.new(self[:status] || "")
  end

  def sent?
    status.sent?
  end

  def flag_message
    event = events.where(type: "flag").order('created_at desc').first
    event.message if event
  end

  # Actions

  def grant(donor, options = {})
    Rails.logger.info "#{donor.name} (#{donor.id}) granting request #{id} from #{user.name} (#{user.id}) for #{book}"
    self.donor = donor
    self.status = "not_sent"
    self.flagged = true if user.address.blank?
    save!
    Event.create_grant! self, options
  end

  def update_user(attributes, message = nil)
    Rails.logger.info "#{user.name} updating request #{id} for #{user.name}: #{attributes.inspect}, message: '#{message}'"
    user.attributes = attributes
    context = :granted if granted?
    return :error if user.invalid?(context)

    self.flagged = false

    event = if user.changed?
      Event.create_update! self, message
    elsif message.present?
      Event.create_message! self, user, message
    end

    save!
    user.save!
    event.type.to_sym if event
  end

  def flag(message)
    Rails.logger.info "#{donor.name} flagging request #{id}: '#{message}'"

    if message.blank?
      self.errors.add(:message, "This is required.")
      return false
    end

    self.flagged = true
    save!
    Event.create_flag! self, message
    true
  end

  def thank(params)
    self.thanked = true
    event_attributes = params[:event].merge(user: user)
    thank_events.build event_attributes
  end
end
