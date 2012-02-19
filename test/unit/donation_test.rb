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

  # Cancel

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

  # Update status

  test "update status sent" do
    assert_difference "@dagny_donation.events.count" do
      @dagny_donation.update_status status: "sent"
    end

    @dagny_donation.reload
    assert @dagny_donation.sent?

    @dagny_request.reload
    assert @dagny_request.sent?

    event = @dagny_donation.events.last
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
    assert_difference "@dagny_donation.events.count" do
      @dagny_donation.update_status status: "received", event: {message: "I got it"}
    end

    @dagny_donation.reload
    assert @dagny_donation.received?

    @dagny_request.reload
    assert @dagny_request.received?

    event = @dagny_donation.events.last
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
    assert_difference "@quentin_donation.events.count" do
      @quentin_donation.update_status status: "received", event: {message: "Thanks!", is_thanks: true, public: false}
    end

    @quentin_donation.reload
    assert @quentin_donation.received?
    assert @quentin_donation.thanked?

    @quentin_request.reload
    assert @quentin_request.received?
    assert @quentin_request.thanked?

    event = @quentin_donation.events.last
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
    assert_difference "@quentin_donation.events.count" do
      @quentin_donation.update_status status: "received", event: {message: "", is_thanks: true, public: false}
    end

    @quentin_donation.reload
    assert @quentin_donation.received?
    assert !@quentin_donation.thanked?

    @quentin_request.reload
    assert @quentin_request.received?
    assert !@quentin_request.thanked?

    event = @quentin_donation.events.last
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

  test "update status is idempotent" do
    assert_no_difference "@quentin_donation.events.count" do
      @quentin_donation.update_status status: "sent"
    end
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
    donation = @howard_request.grant @hugh
    assert donation.flagged?

    event = donation.fix({student_name: "Howard Roark", address: "123 Independence St"}, {message: ""})
    assert !donation.flagged?

    assert_equal "update", event.type
    assert_equal "added a shipping address", event.detail
    assert event.message.blank?, event.message.inspect
  end

  test "fix: updated info" do
    attributes = {student_name: "Quentin Daniels", address: "123 Quantum Ln\nGalt's Gulch, CO"}
    event = @quentin_donation.fix(attributes, {message: "I have a new address"})
    assert !@quentin_donation.flagged?

    assert_equal "update", event.type
    assert_equal "updated shipping info", event.detail
    assert_equal "I have a new address", event.message
  end

  test "fix: message only" do
    event = @quentin_donation.fix({student_name: @quentin.name, address: @quentin.address}, {message: "just a message"})
    assert !@quentin_donation.flagged?

    assert_equal @quentin, event.user
    assert_equal "message", event.type
    assert !event.is_thanks?
    assert_equal "just a message", event.message
  end

  test "fix requires address" do
    event = @dagny_donation.fix({student_name: "Dagny Taggart", address: ""}, {message: "Here you go"})
    assert !@dagny_donation.valid?
  end

  # Metrics

  test "metrics" do
    metrics = Donation.metrics
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}

    assert_equal values['Total'], values['Active'] + values['Canceled'], metrics.inspect
    assert_equal values['Active'], values['Flagged'] + Donation.not_flagged.count, metrics.inspect
    assert_equal values['Active'], values['Thanked'] + Donation.not_thanked.count, metrics.inspect
  end
end
