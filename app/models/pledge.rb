# Represents a pledge by a donor to donate a specific number of books.
class Pledge < ActiveRecord::Base
  belongs_to :user
  belongs_to :referral
  has_many :reminder_entities, as: :entity
  has_many :reminders, through: :reminder_entities
  has_one :testimonial, as: :source

  validates_numericality_of :quantity, only_integer: true, greater_than: 0,
    message: "Please enter a number of books to pledge."

  default_scope order("created_at desc")

  # Returns all unfulfilled pledges.
  def self.unfulfilled
    includes(:user).select {|pledge| !pledge.fulfilled? }
  end

  # Determines if the donor has donated at least as many books as pledged.
  def fulfilled?
    user.donations.active.count >= quantity
  end

  # Creates a Testimonial based on this pledge and its "reason" text.
  def to_testimonial
    Testimonial.new source: self, type: 'donor', title: "From a donor", text: reason, attribution: "#{user.name}, #{user.location}"
  end
end
