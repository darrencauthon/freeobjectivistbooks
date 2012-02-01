require 'bcrypt'

class User < ActiveRecord::Base
  LETMEIN_EXPIRATION = 24.hours

  attr_reader :password

  has_many :requests, order: :created_at, dependent: :destroy
  has_many :pledges, order: :created_at, dependent: :destroy
  has_many :donations, class_name: "Request", foreign_key: "donor_id", order: 'created_at desc', dependent: :nullify

  validates_presence_of :name, :location, :email
  validates_uniqueness_of :email, message: "There is already an account with this email."

  validate :name_must_have_proper_format, on: :create, if: lambda {|user| user.name.present? }

  validates_presence_of :password, on: :create
  validates_presence_of :password_confirmation, if: :password_digest_changed?
  validates_confirmation_of :password, message: "didn't match confirmation"

  validates_presence_of :address, on: :granted, message: "We need your address to send you your book."

  def self.find_by_email(email)
    where("lower(email) = ?", email.downcase).first
  end

  def self.login(email, password)
    user = find_by_email email
    return user if user && user.authenticate(password)
  end

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

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create password
  end

  def authenticate(password)
    password_digest.present? && BCrypt::Password.new(password_digest) == password
  end

  def reset_password(params)
    errors.add(:password, "can't be blank") if params[:password].blank?
    errors.add(:password_confirmation, "can't be blank") if params[:password_confirmation].blank?
    errors.empty? ? update_attributes(params) : false
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
    return :expired if Time.now - timestamp > LETMEIN_EXPIRATION
    auth = letmein_auth params[:timestamp]
    auth == params[:auth] ? :valid : :invalid
  end
end
