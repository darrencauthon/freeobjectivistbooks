class Event < ActiveRecord::Base
  self.inheritance_column = 'class'  # anything other than "type", to let us use "type" for something else

  belongs_to :request
  belongs_to :user
  belongs_to :donor, class_name: "User"

  validates_presence_of :type
  validates_inclusion_of :type, in: %w{grant flag update message}

  validates_presence_of :message, if: "type == 'message'"

  def to
    user == request.user ? donor : request.user
  end

  def to_donor?
    to == donor
  end

  def to_student?
    to == request.user
  end
end
