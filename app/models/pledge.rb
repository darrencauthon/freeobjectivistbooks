class Pledge < ActiveRecord::Base
  belongs_to :user
  belongs_to :referral
  has_many :reminder_entities, as: :entity
  has_many :reminders, through: :reminder_entities
  has_one :testimonial, as: :source

  validates_numericality_of :quantity, only_integer: true, greater_than: 0,
    message: "Please enter a number of books to pledge."

  default_scope order("created_at desc")

  def self.unfulfilled
    includes(:user).select {|pledge| !pledge.fulfilled? }
  end

  def fulfilled?
    user.donations.active.count >= quantity
  end

  def to_testimonial
    Testimonial.new source: self, type: 'donor', title: "From a donor", text: reason, attribution: "#{user.name}, a donor in #{user.location}"
  end
end
