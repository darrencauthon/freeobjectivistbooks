require 'test_helper'

class DonationTest < ActiveSupport::TestCase
  def setup
    super
    @hugh_grants_quentin = donations :hugh_grants_quentin_wants_vos
  end

  test "request" do
    assert_equal @quentin_request, @hugh_grants_quentin.request
  end

  test "user" do
    assert_equal @hugh, @hugh_grants_quentin.user
  end

  test "events" do
    events = @hugh_grants_quentin.events
    assert !events.empty?
    events.each {|event| assert_equal @hugh_grants_quentin, event.donation}
  end
end
