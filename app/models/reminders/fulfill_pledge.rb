class Reminders::FulfillPledge < Reminder
  def self.new_for_entity(pledge)
    new user: pledge.user, pledges: [pledge]
  end

  def self.all_key_entities
    Pledge.unfulfilled
  end
end
