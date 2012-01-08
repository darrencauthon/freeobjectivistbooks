require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @howard = users :howard
    @hugh = users :hugh
    @john = User.new name: "John Galt", email: "galt@gulch.com", location: "Atlantis, CO", password: "dagny",
      password_confirmation: "dagny"
  end

  # Validations

  test "howard is valid" do
    assert @howard.valid?
  end

  test "name is required" do
    @howard.name = nil
    assert @howard.invalid?
  end

  test "email is required" do
    @howard.email = nil
    assert @howard.invalid?
  end

  test "location is required" do
    @howard.location = nil
    assert @howard.invalid?
  end

  test "student fields are not required" do
    @howard.school = nil
    @howard.studying = nil
    assert @howard.valid?
  end

  # Signup

  test "create" do
    assert @john.save
    assert User.exists? @john
  end

  test "password required on create" do
    @john.password = nil
    @john.password_confirmation = nil
    assert !@john.save
  end

  test "password confirmation required on create" do
    @john.password_confirmation = "oops"
    assert !@john.save
  end

  # Login

  test "password" do
    assert !@howard.authenticate("wrong")
    assert @howard.authenticate("roark")
  end

  test "login" do
    user = User.login email: "roark@stanton.edu", password: "roark"
    assert_equal @howard, user
    assert user.errors.empty?, user.errors.inspect
  end

  test "wrong password" do
    user = User.login email: "roark@stanton.edu", password: "wrong"
    assert_equal @howard, user
    assert_match /incorrect/i, user.errors[:base].first
  end

  test "wrong email" do
    user = User.login email: "nobody@nowhere.com", password: "whatever"
    assert_not_nil user
    assert_equal "nobody@nowhere.com", user.email
    assert_match /incorrect/i, user.errors[:base].first
  end

  # Associations

  test "requests" do
    assert_equal [requests(:howard_wants_atlas)], @howard.requests
  end

  test "pledges" do
    assert_equal [pledges(:hugh_5)], @hugh.pledges
  end

  test "donations" do
    assert_equal [requests(:quentin_wants_vos)], @hugh.donations
  end
end
