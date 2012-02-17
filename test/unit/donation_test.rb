require 'test_helper'

class DonationTest < ActiveSupport::TestCase
  # Associations

  test "request" do
    assert_equal @quentin_request, @quentin_donation.request
  end

  test "user" do
    assert_equal @hugh, @quentin_donation.user
  end

  test "events" do
    events = @quentin_donation.events
    assert !events.empty?
    events.each {|event| assert_equal @quentin_donation, event.donation}
  end

  # Scopes

  def verify_scope(scope)
    super Donation, scope
  end

  test "active" do
    verify_scope(:active) {|donation| donation.active?}
  end

  test "canceled" do
    verify_scope(:canceled) {|donation| donation.canceled?}
  end

  test "flagged" do
    verify_scope(:flagged) {|donation| donation.active? && donation.flagged?}
  end

  test "not flagged" do
    verify_scope(:not_flagged) {|donation| donation.active? && !donation.flagged?}
  end

  test "sent" do
    verify_scope(:sent) {|donation| donation.active? && donation.sent?}
  end

  test "not sent" do
    verify_scope(:not_sent) {|donation| donation.active? && !donation.sent?}
  end

  test "received" do
    verify_scope(:received) {|donation| donation.active? && donation.received?}
  end

  test "needs sending" do
    verify_scope(:needs_sending) {|request| request.active? && request.can_send?}
  end

  # Callbacks

  test "default status is not_sent" do
    donation = @howard_request.donations.create user: @hugh
    assert_equal "not_sent", donation.status
  end

  test "canceling donation clears donation from request" do
    @dagny_donation.canceled = true
    @dagny_donation.save!

    @dagny_request.reload
    assert @dagny_request.open?, "request is not open"
  end

  # Derived attributes

  test "student" do
    assert_equal @dagny, @dagny_donation.student
  end

  test "book" do
    assert_equal "Atlas Shrugged", @hank_donation.book
  end

  test "address" do
    assert_equal @hank.address, @hank_donation.address
  end

  test "sent?" do
    assert !@dagny_donation.sent?
    assert @quentin_donation.sent?
    assert @hank_donation_received.sent?
  end

  test "received?" do
    assert !@dagny_donation.received?
    assert !@quentin_donation.received?
    assert @hank_donation_received.received?
  end

  test "can send?" do
    assert @quentin_donation_unsent.can_send?
    assert !@quentin_donation.can_send?  # already sent
    assert !@dagny_donation.can_send?    # flagged
  end

  test "can flag?" do
    assert @quentin_donation_unsent.can_flag?
    assert !@quentin_donation.can_flag?  # already sent
    assert !@dagny_donation.can_flag?    # already flagged
  end

  test "can cancel?" do
    assert @hank_donation.can_cancel?
    assert !@quentin_donation.can_cancel?  # already sent
  end

  # Actions

  test "cancel" do
    event = @hank_donation.cancel(event: {message: "Sorry"})
    assert @hank_donation.canceled?, "donation not canceled"

    assert_equal "cancel", event.type
    assert_equal @hank_request, event.request
    assert_equal @cameron, event.user
    assert_equal @cameron, event.donor
    assert_equal "Sorry", event.message
    assert_not_nil event.happened_at
  end
end
