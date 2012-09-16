# Reminder to a donor to fulfill a Pledge.
class Reminders::FulfillPledge < Reminder
  def self.new_for_entity(pledge)
    new user: pledge.user, pledges: [pledge]
  end

  def self.all_key_entities
    Pledge.unfulfilled
  end

  def key_entity
    pledge
  end

  #--
  # Can send?
  #++

  def too_soon?
    Time.since(pledge.created_at) < 1.week
  end

  def min_interval
    1.week
  end

  def max_reminders
    3
  end
end
