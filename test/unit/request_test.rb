require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def reason
    "I've heard so much about this... can't wait to find out who is John Galt!"
  end

  # Creating

  test "new" do
    request = User.new.requests.build
    assert_equal "Atlas Shrugged", request.book
  end

  test "build" do
    request = @howard.requests.build book: "Atlas Shrugged", other_book: "", reason: reason, pledge: "1"
    assert request.valid?, request.errors.inspect
    assert_equal "Atlas Shrugged", request.book
  end

  test "other book" do
    request = @howard.requests.build book: "other", other_book: "Ulysses", reason: reason, pledge: "1"
    assert request.valid?, request.errors.inspect
    assert_equal "Ulysses", request.book
  end

  test "reason is required" do
    request = @howard.requests.build book: "Atlas Shrugged", other_book: "", reason: "", pledge: "1"
    assert request.invalid?
  end

  test "pledge is required" do
    request = @howard.requests.build book: "Atlas Shrugged", other_book: "", reason: reason
    assert request.invalid?
  end

  # Associations

  test "user" do
    assert_equal @howard, @howard_request.user
  end

  test "donor" do
    assert_nil @howard_request.donor
    assert_equal @hugh, @quentin_request.donor
  end

  test "donation" do
    assert_equal donations(:hugh_grants_quentin_wants_vos), @quentin_request.donation
    assert_nil requests(:quentin_wants_opar).donation
  end

  test "donations" do
    assert_equal [donations(:hugh_grants_quentin_wants_vos)], @quentin_request.donations
    assert_equal [donations(:stadler_grants_quentin_wants_opar)], requests(:quentin_wants_opar).donations
  end

  # Scopes

  def verify_scope(scope)
    super Request, scope
  end

  test "granted" do
    verify_scope(:granted) {|request| request.granted?}
  end

  test "not granted" do
    verify_scope(:not_granted) {|request| request.open?}
  end

  # Derived attributes

  test "address" do
    assert_equal @quentin.address, @quentin_request.address
  end

  test "granted?" do
    assert !@howard_request.granted?
    assert @quentin_request.granted?
  end

  test "needs thanks?" do
    assert !@howard_request.needs_thanks?
    assert @quentin_request.needs_thanks?
    assert !@dagny_request.needs_thanks?
  end

  test "sent?" do
    assert !@howard_request.sent?
    assert !@dagny_request.sent?
    assert @quentin_request.sent?
    assert @hank_request_received.sent?
  end

  test "received?" do
    assert !@howard_request.received?
    assert !@dagny_request.received?
    assert !@quentin_request.received?
    assert @hank_request_received.received?
  end

  test "flag message" do
    assert_equal "Please add your full name and address", @dagny_request.flag_message
  end

  test "review" do
    assert_nil @howard_request.review
    assert_nil @hank_request_received.review
    assert_equal @quentin_review, @quentin_request_read.review
  end

  # Grant

  test "grant" do
    request = @quentin_request_open
    donation = request.grant @hugh

    assert request.granted?
    assert_equal donation, request.donation

    assert_equal @hugh, donation.user
    assert !donation.flagged?
    assert !donation.sent?

    verify_event donation, "grant", user: @hugh
  end

  test "grant no address" do
    donation = @howard_request.grant @hugh

    assert @howard_request.granted?
    assert_equal donation, @howard_request.donation

    assert_equal @hugh, donation.user
    assert donation.flagged?
    assert !donation.sent?

    verify_event donation, "grant", user: @hugh
  end

  # Build update event

  test "build update event" do
    @howard_request.address = "123 Independence St"
    event = @howard_request.build_update_event
    assert_equal "update", event.type
    assert_equal @howard, event.user
    assert_equal "added a shipping address", event.detail
    assert event.message.blank?, event.message.inspect
  end

  test "update requires address if granted" do
    @quentin_request.address = ""
    @quentin_request.valid?
    assert @quentin_request.errors[:address].any?, @quentin_request.errors.inspect
  end
end
