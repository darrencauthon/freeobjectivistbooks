class Reminder < ActiveRecord::Base
  self.inheritance_column = 'class'  # anything other than "type", to let us use "type" for something else

  # Associations

  belongs_to :user
  has_many :reminder_entities, dependent: :destroy
  has_many :pledges, through: :reminder_entities, source: :entity, source_type: 'Pledge'
  has_many :donations, through: :reminder_entities, source: :entity, source_type: 'Donation'

  # Constructors

  def self.new_fulfill_pledge(pledge)
    new type: 'fulfill_pledge', user: pledge.user, pledges: [pledge]
  end

  def self.new_send_books(user)
    new type: 'send_books', user: user, donations: user.donations.needs_sending
  end

  def self.new_confirm_receipt(donation)
    new type: 'confirm_receipt', user: donation.student, donations: [donation]
  end

  def self.new_read_books(donation)
    new type: 'read_books', user: donation.student, donations: [donation]
  end

  def self.reminders_for(type)
    case type.to_sym
    when :fulfill_pledge  then Pledge.unfulfilled.map {|pledge| new_fulfill_pledge pledge}
    when :send_books      then User.donors_with_unsent_books.map {|user| new_send_books user}
    when :confirm_receipt then Donation.needs_receipt.map {|donation| new_confirm_receipt donation}
    when :read_books      then Donation.needs_reading.map {|donation| new_read_books donation}
    else raise "Don't know who should get #{type} reminder"
    end
  end

  def self.send_reminder_mails(type)
    reminders = reminders_for type
    ReminderMailer.send_campaign type, reminders
  end

  # Derived attributes

  def pledge
    pledges.first
  end

  def donation
    donations.first
  end
end
