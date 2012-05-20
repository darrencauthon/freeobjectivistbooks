require 'bcrypt'

class User < ActiveRecord::Base
  include ActiveModel::Validations

  LETMEIN_EXPIRATION = 24.hours

  attr_reader :password

  # Associations

  has_many :requests
  has_many :pledges
  has_many :donations
  has_many :reviews
  belongs_to :referral
  has_many :reminders

  # Validations

  validates_presence_of :name, :location, :email
  validates_uniqueness_of :email, case_sensitive: false, message: "There is already an account with this email."

  validate :name_must_have_proper_format, on: :create, if: lambda {|user| user.name.present? }
  validates :email, email: {message: "is not a valid email address"}, allow_nil: true

  validates_presence_of :password, unless: "password_digest.present?"
  validates_presence_of :password_confirmation, if: :password_digest_changed?
  validates_confirmation_of :password, message: "didn't match confirmation"

  def name_must_have_proper_format
    has_upper = name =~ /[A-Z]/
    has_lower = name =~ /[a-z]/

    if has_upper && !has_lower
      self.name = name.titleize
      errors.add :name, "don't use ALL CAPS"
    end

    if has_lower && !has_upper
      self.name = name.titleize
      errors.add :name, "please use proper capitalization"
    end

    errors.add(:name, "please include full first and last name") if (!has_upper && !has_lower) || name.words.size < 2
  end

  # Scopes and finders

  default_scope order("created_at desc")

  scope :with_email, lambda {|email| where("lower(email) = ?", email.downcase)}

  def self.find_by_email(email)
    with_email(email).first
  end

  def self.login(email, password)
    user = find_by_email email
    return user if user && user.authenticate(password)
  end

  def self.donors_with_unsent_books
    Donation.needs_sending.map {|donation| donation.user}.uniq
  end

  # Callbacks

  before_validation do |user|
    [:name, :email, :location, :school, :studying].each do |attribute|
      value = user.send attribute
      value.strip! if value
      value.squeeze! " " if value
    end
  end

  after_create do |user|
    Rails.logger.info "New user: #{@user.inspect}"
  end

  # Derived attributes

  def is_duplicate?
    query = User.with_email(email)
    query = query.where('id != ?', id) if id
    query.any?
  end

  def update_detail
    if address_was.blank? && address.present?
      "added a shipping address"
    elsif name_was.words.size < 2 && name.words.size >= 2
      "added their full name"
    elsif name_changed? || address_changed?
      "updated shipping info"
    end
  end

  def can_request?
    requests.not_granted.empty?
  end

  # Actions

  def password=(password)
    @password = password
    self.password_digest = password.present? ? BCrypt::Password.create(password) : nil
  end

  def authenticate(password)
    password_digest.present? && BCrypt::Password.new(password_digest) == password
  end

  def letmein_auth(timestamp)
    Digest::SHA1.hexdigest "#{id}:#{timestamp}:#{Rails.application.config.secret_token}"
  end

  def letmein_params
    timestamp = Time.now.iso8601
    auth = letmein_auth timestamp
    {id: id, timestamp: timestamp, auth: auth}
  end

  def letmein?(params)
    timestamp = Time.parse params[:timestamp]
    return :expired if Time.since(timestamp) > LETMEIN_EXPIRATION
    auth = letmein_auth params[:timestamp]
    auth == params[:auth] ? :valid : :invalid
  end
end
