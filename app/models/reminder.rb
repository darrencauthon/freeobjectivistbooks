class Reminder < ActiveRecord::Base
  TYPES = [
    Reminders::FulfillPledge,
    Reminders::SendBooks,
    Reminders::ConfirmReceipt,
    Reminders::ReadBooks,
  ]

  # Associations

  belongs_to :user
  has_many :reminder_entities, dependent: :destroy
  has_many :pledges, through: :reminder_entities, source: :entity, source_type: 'Pledge'
  has_many :donations, through: :reminder_entities, source: :entity, source_type: 'Donation'

  # Constructors

  def self.new_for_entity(donation)
    raise NotImplementedError
  end

  def self.all_key_entities
    raise NotImplementedError
  end

  def self.all_reminders
    all_key_entities.map {|entity| new_for_entity entity}
  end

  # Derived attributes

  def pledge
    pledges.first
  end

  def donation
    donations.first
  end
end
