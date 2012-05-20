class Reminders::SendBooks < Reminder
  def self.new_for_entity(user)
    new user: user, donations: user.donations.needs_sending
  end

  def self.all_key_entities
    User.donors_with_unsent_books
  end
end
