require 'bcrypt'

class User < ActiveRecord::Base
  LETMEIN_EXPIRATION = 24.hours

  attr_reader :password

  has_many :requests, order: :created_at, dependent: :destroy
  has_many :pledges, order: :created_at, dependent: :destroy
  has_many :donations, class_name: "Request", foreign_key: "donor_id", order: :updated_at, dependent: :nullify

  validates_presence_of :name, :location, :email
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

  def possible_dupe?
    @dupe ||= User.where(email: email).count > 1 || User.where(name: name).count > 1
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
