class Reminders::ConfirmReceipt < Reminder
  def self.new_for_entity(donation)
    new user: donation.student, donations: [donation]
  end

  def self.all_key_entities
    Donation.in_transit
  end

  def key_entity
    donation
  end

  # Can send?

  def too_soon?
    Time.since(donation.sent_at) < 1.week
  end

  def min_interval
    1.week
  end

  def max_reminders
    4
  end
end
