require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @howard = users :howard
    @hugh = users :hugh
    @request = requests :howard_wants_atlas
    @quentin_request = requests :quentin_wants_vos
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
    assert_equal @howard, @request.user
  end

  test "donor" do
    assert_nil @request.donor
    assert_equal @hugh, @quentin_request.donor
  end

  # Scopes

  test "open" do
    assert_equal [@request], Request.open.all
  end

  test "donated" do
    assert_equal [@quentin_request], Request.donated.all
  end
end
