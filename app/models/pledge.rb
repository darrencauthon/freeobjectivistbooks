class Pledge < ActiveRecord::Base
  belongs_to :user
  validates_numericality_of :quantity, only_integer: true, greater_than: 0,
    message: "Please enter a number of books to pledge."

  def self.metrics
    metrics = [
      {name: 'Donors pledging',     value: count},
      {name: 'Books pledged',       value: sum(:quantity)},
      {name: 'Average pledge size', value: average(:quantity)},
    ]
  end
end
