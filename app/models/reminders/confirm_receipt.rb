class Reminders::ConfirmReceipt < Reminder
  def self.new_for_entity(donation)
    new user: donation.student, donations: [donation]
  end

  def self.all_key_entities
    Donation.needs_receipt
  end
end
