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

  test "open" do
    verify_scope(:open) {|request| request.open?}
  end

  test "granted" do
    verify_scope(:granted) {|request| request.granted?}
  end

  test "flagged" do
    verify_scope(:flagged) {|request| request.flagged?}
  end

  test "not flagged" do
    verify_scope(:not_flagged) {|request| !request.flagged?}
  end

  test "thanked" do
    verify_scope(:thanked) {|request| request.thanked?}
  end

  test "not thanked" do
    verify_scope(:not_thanked) {|request| !request.thanked?}
  end

  test "sent" do
    verify_scope(:sent) {|request| request.sent?}
  end

  test "not sent" do
    verify_scope(:not_sent) {|request| !request.sent?}
  end

  test "received" do
    verify_scope(:received) {|request| request.received?}
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

  # Update user

  test "update user: added address" do
    event = @howard_request.update_user(user: {name: "Howard Roark", address: "123 Independence St"}, event: {message: ""})

    assert_equal "123 Independence St", @howard_request.address
    assert_equal "update", event.type
    assert_equal "added a shipping address", event.detail
    assert event.message.blank?, event.message.inspect
  end

  test "update user: added name" do
    @dagny.address = "123 Somewhere Rd"
    @dagny.save!

    event = @dagny_request.update_user(user: {name: "Dagny Taggart", address: "123 Somewhere Rd"}, event: {message: "Here you go"})

    assert_equal "Dagny Taggart", @dagny_request.user.name
    assert_equal "update", event.type
    assert_equal "added their full name", event.detail
    assert_equal "Here you go", event.message
  end

  test "new update: updated info" do
    attributes = {name: "Quentin Daniels", address: "123 Quantum Ln\nGalt's Gulch, CO"}
    event = @quentin_request.update_user(user: attributes, event: {message: "I have a new address"})

    assert_equal "123 Quantum Ln\nGalt's Gulch, CO", @quentin_request.address
    assert_equal "update", event.type
    assert_equal "updated shipping info", event.detail
    assert_equal "I have a new address", event.message
  end

  test "new update: message only" do
    event = @quentin_request.update_user(user: {name: @quentin.name, address: @quentin.address}, event: {message: "just a message"})

    assert_equal @quentin, event.user
    assert_equal "message", event.type
    assert !event.is_thanks?
    assert_equal "just a message", event.message
  end

  test "update user requires address if granted" do
    event = @dagny_request.update_user(user: {name: "Dagny Taggart", address: ""}, event: {message: "Here you go"})
    assert !@dagny_request.user_valid?
  end

  # Metrics

  test "metrics" do
    metrics = Request.metrics
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}

    assert_equal values['Total'], values['Granted'] + Request.open.count, metrics.inspect
    assert_equal values['Total'], values['Flagged'] + Request.not_flagged.count, metrics.inspect
    assert_equal values['Granted'], values['Sent'] + Request.not_sent.count, metrics.inspect
    assert_equal values['Total'], values['Thanked'] + Request.not_thanked.count, metrics.inspect
  end

  test "book metrics" do
    metrics = Request.book_metrics
    sum = metrics.inject(0) {|sum,metric| sum += metric[:value]}
    assert_equal Request.count, sum
  end
end
