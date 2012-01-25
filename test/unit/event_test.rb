require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    super
    @new_flag = @dagny_request.events.build type: "flag", user: @hugh, message: "Problem here"
    @new_message = @howard_request.events.build type: "message", user: @hugh, message: "Info is correct"
    @new_thank = @quentin_request.events.build type: "thank", user: @quentin, message: "Thanks!", public: false
  end

  # Associations

  test "request" do
    assert_equal @quentin_request, events(:hugh_grants_quentin).request
  end

  test "user" do
    assert_equal @hugh, events(:hugh_grants_quentin).user
    assert_equal @quentin, events(:quentin_adds_name).user
  end

  test "donor" do
    assert_equal @hugh, events(:hugh_grants_quentin).donor
  end

  # Validations

  test "valid flag" do
    assert @new_flag.valid?
  end

  test "flag requires message" do
    @new_flag.message = ""
    assert @new_flag.invalid?
    assert @new_flag.errors[:message].any?
  end

  test "valid message" do
    assert @new_message.valid?
  end

  test "message requires message" do
    @new_message.message = ""
    assert @new_message.invalid?
    assert @new_message.errors[:message].any?
  end

  test "valid thank" do
    assert @new_thank.valid?
  end

  test "thank requires message" do
    @new_thank.message = ""
    assert @new_thank.invalid?
    assert @new_thank.errors[:message].any?
  end

  test "thank requires explicit public bit" do
    @new_thank.public = nil
    assert @new_thank.invalid?
    assert @new_thank.errors[:public].any?
  end

  test "validates type" do
    @new_flag.type = "random"
    assert @new_flag.invalid?
  end

  # Constructors

  test "create grant" do
    @howard_request.donor = @hugh
    event = Event.create_grant! @howard_request
    assert_equal @howard_request, event.request
    assert_equal @hugh, event.user
    assert_equal @hugh, event.donor
    assert_equal "grant", event.type
    assert_nil event.detail
    assert_nil event.message
  end

  test "create flag" do
    event = Event.create_flag! @quentin_request, "I still can't find this address"
    assert_equal @quentin_request, event.request
    assert_equal @hugh, event.user
    assert_equal @hugh, event.donor
    assert_equal "flag", event.type
    assert_nil event.detail
    assert_equal "I still can't find this address", event.message
  end

  test "create update: added address" do
    @howard_request.user.address = "123 Independence St"
    event = Event.create_update! @howard_request
    assert_equal @howard_request, event.request
    assert_equal @howard, event.user
    assert_nil event.donor
    assert_equal "update", event.type
    assert_equal "added a shipping address", event.detail
    assert_nil event.message
  end

  test "create update: added name" do
    @dagny_request.user.name = "Dagny Taggart"
    event = Event.create_update! @dagny_request, "Here you go"
    assert_equal @dagny_request, event.request
    assert_equal @dagny, event.user
    assert_equal @hugh, event.donor
    assert_equal "update", event.type
    assert_equal "added their full name", event.detail
    assert_equal "Here you go", event.message
  end

  test "create update: updated info" do
    @quentin_request.user.address = "123 Quantum Ln\nGalt's Gulch, CO"
    event = Event.create_update! @quentin_request, "I have a new address"
    assert_equal @quentin_request, event.request
    assert_equal @quentin, event.user
    assert_equal @hugh, event.donor
    assert_equal "update", event.type
    assert_equal "updated shipping info", event.detail
    assert_equal "I have a new address", event.message
  end

  test "create message" do
    event = Event.create_message! @dagny_request, @hugh, "Thanks, I will send your book"
    assert_equal @dagny_request, event.request
    assert_equal @hugh, event.user
    assert_equal @hugh, event.donor
    assert_equal "message", event.type
    assert_nil event.detail
    assert_equal "Thanks, I will send your book", event.message
  end

  # Derived attributes

  test "from" do
    assert_equal @hugh, events(:hugh_grants_quentin).from
    assert_equal @quentin, events(:quentin_adds_name).from
  end

  test "from student?" do
    assert !events(:hugh_grants_quentin).from_student?
    assert events(:quentin_adds_name).from_student?
  end

  test "from donor?" do
    assert events(:hugh_grants_quentin).from_donor?
    assert !events(:quentin_adds_name).from_donor?
  end

  test "to" do
    assert_equal @quentin, events(:hugh_grants_quentin).to
    assert_equal @hugh, events(:quentin_adds_name).to
  end

  test "to student?" do
    assert events(:hugh_grants_quentin).to_student?
    assert !events(:quentin_adds_name).to_student?
  end

  test "to donor?" do
    assert !events(:hugh_grants_quentin).to_donor?
    assert events(:quentin_adds_name).to_donor?
  end

  # Actions

  test "notify" do
    event = events :hugh_messages_quentin
    assert !event.notified?
    assert_difference("ActionMailer::Base.deliveries.count") { event.notify }
    assert event.notified?
    mail = ActionMailer::Base.deliveries.last
    assert_equal "Hugh Akston sent you a message on Free Objectivist Books", mail.subject
  end

  test "notify is idempotent" do
    event = events :quentin_adds_name
    assert event.notified?
    assert_no_difference("ActionMailer::Base.deliveries.count") { event.notify }
  end

  test "notify is noop if no recipient" do
    event = events :howard_updates_info
    assert !event.notified?
    assert_no_difference("ActionMailer::Base.deliveries.count") { event.notify }
  end
end
