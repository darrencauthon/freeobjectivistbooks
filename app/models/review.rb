class Review < ActiveRecord::Base
  # Associations

  belongs_to :user
  belongs_to :donation

  # Validations

  validates_presence_of :user, :book, :text
  validates_inclusion_of :recommend, in: [true, false], message: 'Please choose "Yes" or "No".'

  # Callbacks

  after_initialize :populate

  def populate
    unless id
      self.user ||= donation.student if donation
      self.book ||= donation.book if donation
    end
  end
end
