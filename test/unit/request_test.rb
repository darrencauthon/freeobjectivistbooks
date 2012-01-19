require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @howard = users :howard
    @hugh = users :hugh
    @dagny = users :dagny
    @quentin = users :quentin

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

  # Grant

  test "grant" do
    request = requests :quentin_wants_opar
    assert_difference "request.events.count" do
      request.grant @hugh
    end

    assert request.granted?
    assert !request.flagged?
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
    assert_equal @hugh, @howard_request.donor

    event = @howard_request.events.last
    assert_equal "grant", event.type
  end

  # Flagging

  test "flag" do
    assert_difference "@quentin_request.events.count" do
      assert @quentin_request.flag("Is this address correct?")
    end

    event = @quentin_request.events.last
    assert_equal "flag", event.type
    assert_equal "Is this address correct?", event.message
  end

  test "flag requires message" do
    assert_no_difference "@quentin_request.events.count" do
      assert !@quentin_request.flag("")
    end
  end

  test "flag message" do
    assert_equal "Please add your full name and address", @dagny_request.flag_message
  end

  # Update user

  test "update user: added address" do
    assert_difference "@howard_request.events.count" do
      assert_equal :update, @howard_request.update_user({name: "Howard Roark", address: "123 Independence St"}, "")
    end

    @howard_request.reload
    assert !@howard_request.flagged?

    event = @howard_request.events.last
    assert_equal "update", event.type
    assert_equal "added a shipping address", event.detail
    assert event.message.blank?, event.message
  end

  test "update user: added name" do
    @dagny.address = "123 Somewhere Rd"
    @dagny.save!

    assert_difference "@dagny_request.events.count" do
      assert_equal :update, @dagny_request.update_user({name: "Dagny Taggart", address: "123 Somewhere Rd"}, "Here you go")
    end

    @dagny_request.reload
    assert !@dagny_request.flagged?

    event = @dagny_request.events.last
    assert_equal "update", event.type
    assert_equal "added their full name", event.detail
    assert_equal "Here you go", event.message
  end

  test "new update: updated info" do
    attributes = {name: "Quentin Daniels", address: "123 Quantum Ln\nGalt's Gulch, CO"}
    assert_difference "@quentin_request.events.count" do
      assert_equal :update, @quentin_request.update_user(attributes, "I have a new address")
    end

    @quentin_request.reload
    assert !@quentin_request.flagged?

    event = @quentin_request.events.last
    assert_equal "update", event.type
    assert_equal "updated shipping info", event.detail
    assert_equal "I have a new address", event.message
  end

  test "new update: message only" do
    assert_difference "@quentin_request.events.count" do
      assert_equal :message, @quentin_request.update_user({name: @quentin.name, address: @quentin.address}, "just a message")
    end

    @quentin_request.reload
    assert !@quentin_request.flagged?

    event = @quentin_request.events.last
    assert_equal @quentin, event.user
    assert_equal "message", event.type
    assert_equal "just a message", event.message
  end

  test "update user requires address if granted" do
    assert_no_difference "@dagny_request.events.count" do
      assert_equal :error, @dagny_request.update_user({name: "Dagny Taggart", address: ""}, "Here you go")
    end

    @dagny_request.reload
    assert @dagny_request.flagged?
  end
end
