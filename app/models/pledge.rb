class Pledge < ActiveRecord::Base
  belongs_to :user
  validates_numericality_of :quantity, only_integer: true, greater_than: 0,
    message: "Please enter a number of books to pledge."
end
