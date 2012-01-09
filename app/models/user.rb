require 'bcrypt'

class User < ActiveRecord::Base
  attr_reader :password

  has_many :requests, order: :created_at
  has_many :pledges, order: :created_at
  has_many :donations, class_name: "Request", foreign_key: "donor_id", order: :updated_at

  validates_presence_of :name, :location, :email
  validates_presence_of :password, on: :create
  validates_confirmation_of :password, on: :create, message: "didn't match confirmation"

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
end
