class Reminders::SendBooks < Reminder
  def self.new_for_entity(user)
    new user: user, donations: user.donations.needs_sending
  end

  def self.all_key_entities
    User.donors_with_unsent_books
  end

  def key_entity
    user
  end

  # Can send?

  def min_interval
    4.days
  end

  def max_reminders
    5
  end
end
