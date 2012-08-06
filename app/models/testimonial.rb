class Testimonial < ActiveRecord::Base
  self.inheritance_column = 'class'  # anything other than "type", to let us use "type" for something else

  TYPES = %w{student donor}

  belongs_to :source, polymorphic: true

  validates_presence_of :type, message: "Type is required"
  validates_inclusion_of :type, in: TYPES, if: :type
  validates_numericality_of :priority
end
