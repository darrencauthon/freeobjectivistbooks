require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    super
    @new_flag = @dagny_request.events.build type: "flag", user: @hugh, message: "Problem here"
    @new_message = @howard_request.events.build type: "message", user: @hugh, message: "Info is correct"
    @new_thank = @quentin_request.events.build type: "message", is_thanks: true, user: @quentin, message: "Thanks!", public: false
    @new_cancel = @hank_request.events.build type: "cancel", user: @hugh, message: "Sorry!"
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

  test "donation" do
    assert_equal donations(:hugh_grants_quentin_wants_vos), events(:hugh_grants_quentin).donation
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

  test "thank requires explicit public bit" do
    @new_thank.public = nil
    assert @new_thank.invalid?
    assert @new_thank.errors[:public].any?
  end

  test "valid cancel" do
    assert @new_cancel.valid?
  end

  test "cancel requires message" do
    @new_cancel.message = ""
    assert @new_cancel.invalid?
    assert @new_cancel.errors[:message].any?
  end

  test "validates type" do
    @new_flag.type = "random"
    assert @new_flag.invalid?
  end

  # Derived attributes

  test "book" do
    assert_equal "Atlas Shrugged", events(:cameron_grants_hank).book
  end

  test "student" do
    assert_equal @quentin, events(:hugh_grants_quentin).student
    assert_equal @quentin, events(:quentin_adds_name).student
  end

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
