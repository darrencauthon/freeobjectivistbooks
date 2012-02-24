class Review < ActiveRecord::Base
  # Associations

  belongs_to :user
  belongs_to :donation

  # Validations

  validates_presence_of :user, :book, :text
  validates_inclusion_of :recommend, in: [true, false]
end
