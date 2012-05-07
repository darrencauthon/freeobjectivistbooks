class Reminder < ActiveRecord::Base
  self.inheritance_column = 'class'  # anything other than "type", to let us use "type" for something else

  belongs_to :user
  has_many :reminder_entities, dependent: :destroy
  has_many :pledges, through: :reminder_entities, source: :entity, source_type: 'Pledge'
  has_many :donations, through: :reminder_entities, source: :entity, source_type: 'Donation'
end
