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

  test "review" do
    assert_nil @hank_donation_received.review
    assert_equal @quentin_review, @quentin_donation_read.review
  end

  test "reminders" do
    assert_equal [@cameron_reminder], @hank_donation.reminders
    assert_equal [@cameron_reminder], @hank_donation_received.reminders
    assert_equal [], @quentin_donation.reminders
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

  test "thanked" do
    verify_scope(:thanked) {|donation| donation.active? && donation.thanked?}
  end

  test "not thanked" do
    verify_scope(:not_thanked) {|donation| donation.active? && !donation.thanked?}
  end

  test "flagged" do
    verify_scope(:flagged) {|donation| donation.active? && donation.flagged?}
  end

  test "not flagged" do
    verify_scope(:not_flagged) {|donation| donation.active? && !donation.flagged?}
  end

  test "not sent" do
    verify_scope(:not_sent) {|donation| donation.active? && !donation.sent?}
  end

  test "sent" do
    verify_scope(:sent) {|donation| donation.active? && donation.sent?}
  end

  test "in transit" do
    verify_scope(:in_transit) {|donation| donation.active? && donation.sent? && !donation.received?}
  end

  test "received" do
    verify_scope(:received) {|donation| donation.active? && donation.received?}
  end

  test "reading" do
    verify_scope(:reading) {|donation| donation.active? && donation.received? && !donation.read?}
  end

  test "read" do
    verify_scope(:read) {|donation| donation.active? && donation.read?}
  end

  test "needs sending" do
    verify_scope(:needs_sending) {|donation| donation.active? && donation.can_send?}
  end

  # Callbacks

  test "default status is not_sent" do
    donation = @howard_request.donations.create user: @hugh
    assert_equal "not_sent", donation.status
    assert_equal donation.created_at, donation.status_updated_at
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

  test "sent at" do
    assert_nil @dagny_donation.sent_at
    assert_equal events(:hugh_updates_quentin).happened_at, @quentin_donation.sent_at
    assert_equal events(:cameron_updates_hank).happened_at, @hank_donation_received.sent_at
  end

  test "in transit?" do
    assert !@dagny_donation.in_transit?
    assert @quentin_donation.in_transit?
    assert !@hank_donation_received.in_transit?
  end

  test "received?" do
    assert !@dagny_donation.received?
    assert !@quentin_donation.received?
    assert @hank_donation_received.received?
    assert @quentin_donation_read.received?
  end

  test "reading?" do
    assert !@quentin_donation.reading?
    assert @hank_donation_received.reading?
    assert !@quentin_donation_read.reading?
  end

  test "read?" do
    assert !@quentin_donation.read?
    assert !@hank_donation_received.read?
    assert @quentin_donation_read.read?
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

  # Cancel

  test "cancel" do
    event = @hank_donation.cancel event: {message: "Sorry"}
    assert @hank_donation.canceled?, "donation not canceled"

    assert_equal "cancel_donation", event.type
    assert_equal @hank_request, event.request
    assert_equal @cameron, event.user
    assert_equal @cameron, event.donor
    assert_equal "Sorry", event.message
    assert_not_nil event.happened_at
  end

  # Update status

  test "update status sent" do
    time = Time.now
    event = @dagny_donation.update_status status: "sent"

    assert @dagny_donation.sent?
    assert @dagny_donation.status_updated_at >= time

    assert_equal @dagny_donation, event.donation
    assert_equal @dagny_request, event.request
    assert_equal @hugh, event.user
    assert_equal @hugh, event.donor
    assert_equal "update_status", event.type
    assert_equal "sent", event.detail
    assert_nil event.message
    assert_not_nil event.happened_at
  end

  test "update status received" do
    time = Time.now
    event = @dagny_donation.update_status status: "received", event: {message: "I got it"}

    assert @dagny_donation.received?
    assert @dagny_donation.status_updated_at >= time

    assert_equal @dagny_donation, event.donation
    assert_equal @dagny_request, event.request
    assert_equal @dagny, event.user
    assert_equal @hugh, event.donor
    assert_equal "update_status", event.type
    assert_equal "received", event.detail
    assert_equal "I got it", event.message
    assert !event.is_thanks?
    assert_not_nil event.happened_at
  end

  test "update status received with thank-you" do
    event = @quentin_donation.update_status status: "received", event: {message: "Thanks!", is_thanks: true, public: false}
    assert @quentin_donation.received?

    assert_equal @quentin_donation, event.donation
    assert_equal @quentin_request, event.request
    assert_equal @quentin, event.user
    assert_equal @hugh, event.donor
    assert_equal "update_status", event.type
    assert_equal "received", event.detail
    assert_equal "Thanks!", event.message
    assert event.is_thanks?
    assert !event.public?
    assert_not_nil event.happened_at
  end

  test "update status received with empty thank-you" do
    event = @quentin_donation.update_status status: "received", event: {message: "", is_thanks: true, public: false}
    assert @quentin_donation.received?

    assert_equal @quentin_donation, event.donation
    assert_equal @quentin_request, event.request
    assert_equal @quentin, event.user
    assert_equal @hugh, event.donor
    assert_equal "update_status", event.type
    assert_equal "received", event.detail
    assert !event.is_thanks?
    assert_nil event.public
    assert_not_nil event.happened_at
  end

  test "update status read" do
    time = Time.now
    event = @hank_donation_received.update_status status: "read"

    assert @hank_donation_received.read?
    assert @hank_donation_received.status_updated_at >= time

    assert_equal @hank, event.user
    assert_equal "update_status", event.type
    assert_equal "read", event.detail
  end

  # Flag

  test "flag" do
    event = @quentin_donation.flag(message: "Is this address correct?")
    assert @quentin_donation.flagged?
    assert_equal "flag", event.type
    assert_equal "Is this address correct?", event.message
  end

  test "flag message" do
    assert_equal "Please add your full name and address", @dagny_donation.flag_message
  end

  # Fix

  test "fix: added address" do
    @howard_request.grant @hugh
    @howard_request.save!
    donation = @howard_request.donation
    assert donation.flagged?

    event = donation.fix({student_name: "Howard Roark", address: "123 Independence St"}, {message: ""})
    assert !donation.flagged?

    assert_equal "fix", event.type
    assert_equal "added a shipping address", event.detail
    assert event.message.blank?, event.message.inspect
  end

  test "fix: updated info" do
    attributes = {student_name: "Quentin Daniels", address: "123 Quantum Ln\nGalt's Gulch, CO"}
    event = @quentin_donation.fix(attributes, {message: "I have a new address"})
    assert !@quentin_donation.flagged?

    assert_equal "fix", event.type
    assert_equal "updated shipping info", event.detail
    assert_equal "I have a new address", event.message
  end

  test "fix: message only" do
    event = @quentin_donation.fix({student_name: @quentin.name, address: @quentin.address}, {message: "just a message"})
    assert !@quentin_donation.flagged?

    assert_equal @quentin, event.user
    assert_equal "fix", event.type
    assert !event.is_thanks?
    assert_equal "just a message", event.message
  end

  test "fix requires address" do
    event = @dagny_donation.fix({student_name: "Dagny Taggart", address: ""}, {message: "Here you go"})
    assert !@dagny_donation.valid?
  end
end
