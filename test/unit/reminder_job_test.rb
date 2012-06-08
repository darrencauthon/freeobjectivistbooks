require 'test_helper'

class ReminderJobTest < ActiveSupport::TestCase
  test "send all reminders" do
    Mailgun::Campaign.test_mode = true

    expected = 0
    expected += Pledge.unfulfilled.size
    expected += User.donors_with_unsent_books.count
    expected += Donation.needs_sending.count
    expected += Donation.in_transit.count
    expected += Donation.reading.count
    assert expected > 0

    assert_difference "ActionMailer::Base.deliveries.size", expected do
      ReminderJob.send_all_reminders
    end
  end
end
