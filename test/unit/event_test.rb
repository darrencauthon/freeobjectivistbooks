require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @howard = users :howard
    @quentin = users :quentin
    @hugh = users :hugh
    @dagny = users :dagny

    @howard_request = requests :howard_wants_atlas
    @quentin_request = requests :quentin_wants_vos
    @dagny_request = requests :dagny_wants_cui
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

  test "validates type" do
    assert Event.new(type: "random").invalid?
  end

  # Constructors

  test "new update: added address" do
    @howard_request.user.address = "123 Independence St"
    event = Event.new_update @howard_request
    assert_equal @howard_request, event.request
    assert_equal @howard, event.user
    assert_nil event.donor
    assert_equal "update", event.type
    assert_equal "added a shipping address", event.detail
    assert_nil event.message
  end

  test "new update: added name" do
    @dagny_request.user.name = "Dagny Taggart"
    event = Event.new_update @dagny_request, "Here you go"
    assert_equal @dagny_request, event.request
    assert_equal @dagny, event.user
    assert_equal @hugh, event.donor
    assert_equal "update", event.type
    assert_equal "added their full name", event.detail
    assert_equal "Here you go", event.message
  end

  test "new update: updated info" do
    @quentin_request.user.address = "123 Quantum Ln\nGalt's Gulch, CO"
    event = Event.new_update @quentin_request, "I have a new address"
    assert_equal @quentin_request, event.request
    assert_equal @quentin, event.user
    assert_equal @hugh, event.donor
    assert_equal "update", event.type
    assert_equal "updated shipping info", event.detail
    assert_equal "I have a new address", event.message
  end

  test "new message" do
    event = Event.new_message @dagny_request, @hugh, "Thanks, I will send your book"
    assert_equal @dagny_request, event.request
    assert_equal @hugh, event.user
    assert_equal @hugh, event.donor
    assert_equal "message", event.type
    assert_nil event.detail
    assert_equal "Thanks, I will send your book", event.message
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
