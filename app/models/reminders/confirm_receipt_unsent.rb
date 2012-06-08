class Reminders::ConfirmReceiptUnsent < Reminder
  def self.new_for_entity(donation)
    new user: donation.student, donations: [donation]
  end

  def self.all_key_entities
    Donation.needs_sending.includes(request: :user)
  end

  def key_entity
    donation
  end

  # Can send?

  def too_soon?
    !donation.student_can_cancel?
  end

  def min_interval
    1.week
  end

  def max_reminders
    3
  end
end
