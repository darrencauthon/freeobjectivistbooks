class Pledge < ActiveRecord::Base
  belongs_to :user
  belongs_to :referral
  has_many :reminder_entities, as: :entity
  has_many :reminders, through: :reminder_entities

  validates_numericality_of :quantity, only_integer: true, greater_than: 0,
    message: "Please enter a number of books to pledge."

  default_scope order("created_at desc")

  def self.unfulfilled
    all.select {|pledge| !pledge.fulfilled? }
  end

  def fulfilled?
    user.donations.active.count >= quantity
  end
end
