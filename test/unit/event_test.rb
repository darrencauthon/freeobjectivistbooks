require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @quentin = users :quentin
    @hugh = users :hugh
    @quentin_wants_vos = requests :quentin_wants_vos
  end

  # Associations

  test "request" do
    assert_equal @quentin_wants_vos, events(:hugh_grants_quentin).request
  end

  test "user" do
    assert_equal @hugh, events(:hugh_grants_quentin).user
    assert_equal @quentin, events(:quentin_adds_name).user
  end

  test "donor" do
    assert_equal @hugh, events(:hugh_grants_quentin).donor
  end

  # Validations

  test "validates type" do
    assert Event.new(type: "random").invalid?
  end

  # Derived attributes

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
