class ReminderEntity < ActiveRecord::Base
  belongs_to :reminder
  belongs_to :entity, polymorphic: true
end
