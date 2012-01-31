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

  # Scopes

  test "open" do
    open = Request.open
    assert open.any?
    open.each {|request| assert request.open?}
  end

  test "granted" do
    granted = Request.granted
    assert granted.any?
    granted.each {|request| assert request.granted?}
  end

  test "flagged" do
    flagged = Request.flagged
    assert flagged.any?
    flagged.each {|request| assert request.flagged?}
  end

  test "not flagged" do
    not_flagged = Request.not_flagged
    assert not_flagged.any?
    not_flagged.each {|request| assert !request.flagged?}
  end

  test "thanked" do
    thanked = Request.thanked
    assert thanked.any?
    thanked.each {|request| assert request.thanked?}
  end

  test "not sent" do
    requests = Request.not_sent
    assert requests.any?
    requests.each {|request| assert !request.sent?}
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
  end

  # Grant

  test "grant" do
    request = requests :quentin_wants_opar
    assert_difference "request.events.count" do
      request.grant @hugh
    end

    assert request.granted?
    assert !request.flagged?
    assert !request.sent?
    assert_equal @hugh, request.donor

    event = request.events.last
    assert_equal "grant", event.type
  end

  test "grant no address" do
    assert_difference "@howard_request.events.count" do
      @howard_request.grant @hugh
    end

    assert @howard_request.granted?
    assert @howard_request.flagged?
    assert !@howard_request.sent?
    assert_equal @hugh, @howard_request.donor

    event = @howard_request.events.last
    assert_equal "grant", event.type
  end

  # Flagging

  test "flag" do
    event = @quentin_request.flag(event: {message: "Is this address correct?"})
    assert @quentin_request.flagged?
    assert_equal "flag", event.type
    assert_equal "Is this address correct?", event.message
  end

  test "flag message" do
    assert_equal "Please add your full name and address", @dagny_request.flag_message
  end

  # Update user

  test "update user: added address" do
    event = @howard_request.update_user(user: {name: "Howard Roark", address: "123 Independence St"}, event: {message: ""})
    assert !@howard_request.flagged?

    assert_equal "update", event.type
    assert_equal "added a shipping address", event.detail
    assert event.message.blank?, event.message.inspect
  end

  test "update user: added name" do
    @dagny.address = "123 Somewhere Rd"
    @dagny.save!

    event = @dagny_request.update_user(user: {name: "Dagny Taggart", address: "123 Somewhere Rd"}, event: {message: "Here you go"})
    assert !@dagny_request.flagged?

    assert_equal "update", event.type
    assert_equal "added their full name", event.detail
    assert_equal "Here you go", event.message
  end

  test "new update: updated info" do
    attributes = {name: "Quentin Daniels", address: "123 Quantum Ln\nGalt's Gulch, CO"}
    event = @quentin_request.update_user(user: attributes, event: {message: "I have a new address"})
    assert !@quentin_request.flagged?

    assert_equal "update", event.type
    assert_equal "updated shipping info", event.detail
    assert_equal "I have a new address", event.message
  end

  test "new update: message only" do
    event = @quentin_request.update_user(user: {name: @quentin.name, address: @quentin.address}, event: {message: "just a message"})
    assert !@quentin_request.flagged?

    assert_equal @quentin, event.user
    assert_equal "message", event.type
    assert_equal "just a message", event.message
  end

  test "update user requires address if granted" do
    event = @dagny_request.update_user(user: {name: "Dagny Taggart", address: ""}, event: {message: "Here you go"})
    assert !@dagny_request.user_valid?
  end

  # Update status

  test "update status" do
    assert_difference "@dagny_request.events.count" do
      @dagny_request.update_status status: "sent", event: {user: @hugh}
    end

    assert @dagny_request.sent?

    event = @dagny_request.events.last
    assert_equal @dagny_request, event.request
    assert_equal @hugh, event.user
    assert_equal @hugh, event.donor
    assert_equal "update_status", event.type
    assert_equal "sent", event.detail
    assert_nil event.message
    assert_not_nil event.happened_at
  end

  # Thank

  test "thank" do
    event = @dagny_request.thank event: {message: "Thanks a lot!", public: true}
    assert @dagny_request.thanked?

    assert_equal @dagny_request, event.request
    assert_equal @dagny, event.user
    assert_equal @hugh, event.donor
    assert_equal "thank", event.type
    assert_equal "Thanks a lot!", event.message
    assert_not_nil event.happened_at
    assert event.public?
  end
end
