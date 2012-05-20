class Reminder < ActiveRecord::Base
  TYPES = [
    Reminders::FulfillPledge,
    Reminders::SendBooks,
    Reminders::ConfirmReceipt,
    Reminders::ReadBooks,
  ]

  def self.type_name
    name.demodulize.underscore
  end

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
    []
  end

  def self.all_reminders
    all_key_entities.map {|entity| new_for_entity entity}
  end

  # Can send?

  def too_soon?
    false
  end

  def min_interval
    1.week
  end

  def max_reminders
    3
  end

  def can_send?
    if too_soon?
      Rails.logger.info "Too soon for #{self}"
      return false
    end

    latest = latest_reminder
    if latest && Time.since(latest.created_at) < min_interval
      Rails.logger.info "Just sent #{self} at #{latest.created_at}"
      return false
    end

    count = past_reminder_count
    if count >= max_reminders
      Rails.logger.info "Already sent #{count} of #{self}"
      return false
    end

    true
  end

  # Other derived attributes

  def type_name
    self.class.type_name
  end

  def pledge
    pledges.first
  end

  def donation
    donations.first
  end

  def key_entity
    nil
  end

  def latest_reminder
    key_entity.reminders.where(type: type, user_id: user).reorder(:created_at).last
  end

  def past_reminder_count
    # We want the minimum past reminder count among all entities this reminder is for.
    (donations + pledges).map {|entity| entity.reminders.count}.min
  end

  def to_s
    "#{type_name} re #{key_entity.class} #{key_entity.id}"
  end
end
