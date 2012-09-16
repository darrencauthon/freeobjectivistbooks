# Join class that tracks which Reminders were sent for which Donations, Pledges, etc.
class ReminderEntity < ActiveRecord::Base
  belongs_to :reminder
  belongs_to :entity, polymorphic: true
end
