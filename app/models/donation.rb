class Donation < ActiveRecord::Base
  belongs_to :request
  belongs_to :user
  has_many :events
end
