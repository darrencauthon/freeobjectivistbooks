require 'bcrypt'

class User < ActiveRecord::Base
  attr_reader :password

  validates_presence_of :name, :location, :email
  validates_presence_of :password, on: :create
  validates_confirmation_of :password, on: :create, message: "didn't match confirmation"

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create password
  end

  def authenticate(password)
    password_digest.present? && BCrypt::Password.new(password_digest) == password
  end
end
