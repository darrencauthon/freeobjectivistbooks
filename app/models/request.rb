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
  scope :not_flagged, where(flagged: [false, nil])
  scope :thanked, where(thanked: true)
  scope :not_thanked, where(thanked: [false, nil])
  scope :sent, scoped_by_status("sent")
  scope :not_sent, scoped_by_status("not_sent")

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

  def open?
    !granted?
  end

  def needs_thanks?
    granted? && !thanked?
  end

  def can_send?
    !sent? && !flagged?
  end

  def can_flag?
    !sent? && !flagged?
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

  def user_valid?
    open? || user.valid?(:granted)
  end

  # Actions

  def grant(donor, options = {})
    self.donor = donor
    self.status = "not_sent"
    self.flagged = true if user.address.blank?
    self.thanked = false
    save!
    grant_events.create options
  end

  def update_user(params)
    user.attributes = params[:user]
    self.flagged = false

    event_attributes = params[:event]
    if user.changed?
      event_attributes[:detail] = if user.address_was.blank? && user.address.present?
        "added a shipping address"
      elsif user.name_was.words.size < 2 && user.name.words.size >= 2
        "added their full name"
      elsif user.name_changed? || user.address_changed?
        "updated shipping info"
      end
      update_events.build event_attributes
    elsif granted?
      event_attributes[:user] = user
      message_events.build event_attributes
    end
  end

  def flag(params)
    self.flagged = true
    flag_events.build params[:event]
  end

  def update_status(params)
    self.status = params[:status]
    return unless changed?
    save!
    update_status_events.create params[:event]
  end

  def thank(params)
    self.thanked = true
    thank_events.build params[:event]
  end

  # Metrics

  def self.metrics
    metrics = [
      {name: 'Total',   value: count},
      {name: 'Granted', value: granted.count, denominator: 'Total'},
      {name: 'Sent',    value: sent.count,    denominator: 'Granted'},
      {name: 'Flagged', value: flagged.count, denominator: 'Granted'},
      {name: 'Thanked', value: thanked.count, denominator: 'Granted'},
    ]

    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}

    metrics.each do |metric|
      denominator = metric[:denominator]
      metric[:percent] = metric[:value].to_f / values[denominator] if denominator && metric[:value] > 0
    end
  end

  def self.book_metrics
    counts = group(:book).count.map {|book,count| {name: book, value: count}}
    counts.sort {|a,b| b[:value] <=> a[:value]}
  end
end
