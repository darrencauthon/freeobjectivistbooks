require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @howard = users :howard
    @hugh = users :hugh
    @dagny = users :dagny

    @howard_request = requests :howard_wants_atlas
    @quentin_request = requests :quentin_wants_vos
    @dagny_request = requests :dagny_wants_cui
  end

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

  # Update user

  test "update user: added address" do
    assert @howard_request.update_user({name: "Howard Roark", address: "123 Independence St"}, "")
    event = @howard_request.events.last
    assert Event.exists?(event)
    assert_equal "update", event.type
    assert_equal "added a shipping address", event.detail
    assert event.message.blank?, event.message
  end

  test "update user: added name" do
    assert @dagny_request.update_user({name: "Dagny Taggart", address: ""}, "Here you go")
    event = @dagny_request.events.last
    assert_equal "update", event.type
    assert_equal "added their full name", event.detail
    assert_equal "Here you go", event.message
  end

  test "new update: updated info" do
    attributes = {name: "Quentin Daniels", address: "123 Quantum Ln\nGalt's Gulch, CO"}
    assert @quentin_request.update_user(attributes, "I have a new address")
    event = @quentin_request.events.last
    assert_equal "update", event.type
    assert_equal "updated shipping info", event.detail
    assert_equal "I have a new address", event.message
  end

  test "new update: message only" do
    assert @dagny_request.update_user({name: @dagny.name, address: @dagny.address}, "just a message")
    event = @dagny_request.events.last
    assert_equal @dagny, event.user
    assert_equal "message", event.type
    assert_equal "just a message", event.message
  end
end
